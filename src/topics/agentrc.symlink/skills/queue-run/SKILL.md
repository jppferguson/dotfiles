---
name: queue-run
description: Coordinate several parallel agent workers through a task queue (doto or similar), with one ship at a time and batched deploys handled by a separate deploy worker. Orchestrator-agnostic; adapters cover Orca, Claude Code subagents and others. Use when the user asks to "work through the queue with N workers", "run the todo column in parallel", "/queue-run", or to coordinate multiple agents shipping tasks to one main branch.
---

# queue-run

Run a task queue with N parallel task workers while you coordinate. You never implement tasks yourself. Your job is to start workers, serialise their ships onto main, batch their deploys, keep a state file, and report.

The protocol below is orchestrator-neutral. It needs six primitives, mapped per orchestrator in `references/adapters.md`:

| Primitive | What it must do |
| --- | --- |
| `spawn(brief)` | Start a worker with a self-contained brief; return a handle |
| `ask` (worker side) | Worker sends a question and blocks until the coordinator replies |
| `reply(question, text)` | Answer a worker's blocking question |
| `send(handle, text)` | Non-blocking message, either direction |
| `wait()` | Coordinator blocks until any worker message arrives (done, question, status, escalation) |
| `release(handle)` | End a finished worker and free its resources |

If the orchestrator has no blocking ask, emulate it: the worker sends a question message and polls for a reply addressed to it.

## Step 0: Load the project profile

The project-specific parts (how to pick a task, how to ship, how to deploy, how to finalise, known hazards) live in a profile, not in this skill. Look for, in order:

1. A path passed as an argument
2. `.agents/queue/profile.md`
3. `.claude/queue/profile.md`

If none exists, build one with the user from `templates/profile.md` before starting any worker. Do not guess deploy or ship commands.

Also read the adapter for the orchestrator you are running under. If the user has not said which, use whichever multi-agent tool the session actually has, and say which you picked.

## Step 1: Set up the run

- **Worker count:** run `~/.agentrc/scripts/agent-capacity.sh` (pass the profile's `--per-worker-gb` if it sets one) and use the smaller of its `workers=` figure and what the user asked for (default 3). Re-run it before every replacement worker; if it has dropped, let the pool shrink instead of replacing. If it reports 0, start nothing: tell the user the machine is short of memory and re-check every few minutes (a background `until` loop on the script, not a sleep).
- **Model mix:** if the profile allows Codex workers, alternate Claude and Codex workers. Each worker's cross-model review then uses the other family, as the pickup skill requires.
- **Rela baselines:** each task's baseline is its own `Rela snapshot:` line (from refinement, or taken when its worker claims it). Record each in the state file next to the task.
- **Models:** task workers on the profile's model (often the session default); the deploy worker on a cheap model (it only runs commands and reads status).
- **Scratchpad:** write the filled-in worker brief (`templates/worker-brief.md` + profile), the deploy brief (`templates/deploy-brief.md` + profile), and a state file `queue-state.md` (layout below).
- Start N task workers.

## Step 2: The coordinator loop

Keep exactly one `wait()` outstanding. Many orchestrators allow only one waiter per run, and a second fails. When it returns, handle each message, update the state file, acknowledge, and wait again. Heartbeat-only messages need an acknowledgement and nothing else.

### Ship lock (one ship at a time)

Concurrent squash-merges onto a shared main race each other. Workers therefore ask before shipping:

- Worker asks `READY TO SHIP <task> <title>` and blocks.
- If nobody holds the lock, reply `GO` and record the holder. Otherwise queue the question by its message id and reply later, in order.
- The worker sends `SHIP DONE <task> <sha>` the moment its merge is pushed. That releases the lock. Deploying is **not** inside the lock.
- In every GO, name what has landed on main since the worker started if it may conflict ("rebase; X just reshaped file Y").
- Before replying GO, check that the worker's two numstats (`main...HEAD` and `main HEAD`) match. If they differ, its base is stale and the merge would revert another commit, so reply "rebase first" instead. On one run, 5 of 9 ships needed this.
- Before every GO, run the Rela drift check from `~/.agentrc/references/rela-gate.md` against that task's own baseline. Never advance a shared baseline. If a decision or an open brief proposal affects the task, reply `HOLD <reason>` instead of GO: the worker comments on the task, hands it back and finishes without shipping. Tell the user once per change, not once per worker.
- Every GO names the head sha it approves. A worker ships only at that sha, so a GO that arrives late or twice cannot ship unreviewed work.
- Put every instruction in the GO itself ("don't finalise", "no deploy"). A follow-up correction can arrive after the worker has acted on it.
- On an orchestrator where idle notices and replies cross (Claude Code subagents), expect duplicate replies. Resend a GO only once, and ignore a repeated SHIP DONE.

### Two coordinators on two machines

Two coordinators can run the same project from different machines, for example one per Mac. They share nothing but doto and the git remote, so the protocol leans on those:

- **One lane each.** The profile's `## Lanes` section maps each coordinator to a lane tag (`lane:<name>`). Pass `--lane <name>` in every worker brief so `next-task` skips the other lane's tasks. Untagged tasks are shared. The doto lease decides who gets one, because `pick_next_task` never returns a task that is already in progress.
- **The ship lock stays local; git is the lock between machines.** Each coordinator still serialises its own workers' ships. Across machines, the push to `main` is atomic. A worker whose push is rejected rebases, revalidates and pushes again, as `next-task` describes. Before a GO, also check whether `origin/main` moved since the worker's last rebase. If it did, reply "rebase first", as for a stale base.
- **Only hand back your own tasks.** The stale-claim sweep below may return a task to the queue only if it was claimed by one of your workers (the `leaseHost` field, or the actor in your state file). Report anything else that looks stuck to the user, rather than touching it.
- **A pre-deploy check on both machines** is harmless, because the push itself triggers the deploy (see the profile). If the profile has a deploy command instead, only the coordinator that pushed requests it.
- **Same-machine alternative.** If the orchestrator can place workers on another machine (Orca: `worker-start --on <environment>`), one coordinator can run both lanes with a single ship lock. Prefer that while both machines are awake. Use two coordinators when one machine sleeps or travels.

### Stale claims

Every 30 minutes, and on every resume, look for your own `in_progress` tasks where the lease has lapsed and the worker's branch has no commit for 30 minutes:

1. Ask the worker. If it's alive and working (a long build, say), let it refresh its lease.
2. If the worker is gone, or it's alive but the task has no commits, hand the task back with `return_task_to_todo` and a reason comment, and remove the worktree once anything worth keeping is pushed to a branch.

An unattended claim with no lease and no work blocks everything behind it until someone notices.

**Conditional GO for live-host work.** If the task touches something running on the host (launchd/systemd jobs, a reverse-proxy config, process killers, cron definitions, credentials), make the GO conditional: the worker must confirm that no committed test can reach the real thing (stubs injected by absolute path or environment, not PATH order alone) and that its own testing left the live config unchanged. Check it yourself after the ship. Once the change is live, check the running result as well as the config: which domain or session the service now runs in, whether its children still reach the credentials they need, and whether the process count is unchanged. A watchdog moved to a system domain once left every child process without login-keychain access, and nothing noticed for an hour.

### Epics: one integration branch, one deploy

When the user wants an epic's children built in parallel but shipped together:

- Cut a local integration branch from main.
- Workers branch from it and stay in their own scope. They squash, then fast-forward into it with `git push --no-verify . HEAD:refs/heads/<branch>`. Skip the pre-push hook on these local pushes: its lock can block for minutes, and the worker's own checks are the gate.
- Run children that touch disjoint files in parallel, and start dependants only once their base has landed.
- When all children are in, rebase a copy onto main in a fresh worktree and run the affected checks once. Then squash it to main as one commit referencing every child, request one deploy, and verify the live result.

### Hand-off and deploy batching

Task workers stop at the push. After SHIP DONE they record the commit and their review verdict in the tracker, then finish with a done message whose first line is exactly:

```text
HANDOFF <task id> sha=<merge sha> verdict=<passed|needs_human|none> deploy=<needed|skip-test-only|skip-no-app> acs=<checked>/<total>
```

On each HANDOFF:

1. Release the worker and start a replacement (unless the queue is exhausted, see Step 3).
2. Append the line, minus `acs`, to `deploy-queue.txt`.
3. If no deploy worker is running, move the queue to `batch-<n>.txt` and spawn a deploy worker with it.

When a deploy worker finishes, release it and start the next batch if the queue is non-empty. Never add work to a running deploy worker by message: it may already be finishing and will miss it. Queue it for the next batch.

The deploy worker's only exit condition is **coverage**: a successful deploy whose commit has every batch SHA as an ancestor. Never wait for "nothing pending", because while workers keep shipping something nearly always is. A single deploy usually covers several tasks.

If the batch is one no-deploy task that only needs finalising, do the finalise yourself. A whole worker for one call is waste.

### Escalations

Workers escalate when they hit something only the coordinator or user can fix (they broke shared state, a hook blocks them, a credential is missing). Check the claim against the live system before acting. Restore shared state to its on-disk or documented form rather than improvising. Tell the worker what you did.

### Interruptions from the user

The user may ask questions mid-run. Answer them, and keep the waiter running; do not let a conversation stall the queue.

### Resuming after a coordinator restart

A coordinator restart (a resume, a crash, or compaction into a new process) can kill the background workers with no notice. Before you spawn anything new, reconcile every worker the state file lists as active:

- If the task is in review with a commit on its branch that is not on main, first check how it ships under the profile. If it ships by PR (for example `requiresHumanReview: true`) and a PR already exists, leave it for the human. Otherwise review it, run the Rela drift check against its baseline, take the ship lock and ship it yourself the way the profile says.
- If the task is in progress with an expired lease, check its worktree. Hand the task back to the queue with a reason if nothing was committed, or resume it in that worktree if work exists.
- If you find uncommitted churn that is only build output (lockfiles, generated pod files), discard it and remove the worktree.

Record what you did in the state file.

### Deploy coverage when one app keeps failing

If a single app fails every drain for an unrelated reason, no drain ever reports overall success. Judge coverage per app instead: the drain's head contains the batch SHAs, and every app the batch touched shows `done`. Report the failing app separately.

## Step 3: Winding down

When a worker reports that the tracker has nothing eligible left, release it without a replacement. From then on, release each worker on its done message, finish the ship queue and deploy batches, then confirm with the orchestrator that no worker is left unreleased.

## Step 4: Report

Give the user:

- Totals: shipped, done, in review, handed back.
- Done tasks with SHAs.
- The review queue grouped by what the human must do: sign-off only, checks a worker could not do (screenshots, device testing), and decisions (unmet criteria, trade-offs).
- Anything you changed outside a task (restored a service, recreated a process) and anything left open.

## State file

Keep `queue-state.md` current after every message, so a compaction or crash loses nothing:

- Goal and user constraints (worker count, models, what not to touch)
- How the loop runs: the exact commands and templates for this orchestrator
- Current: lock holder and queue, active worker handles, deploy worker and its batch, deploy queue, last acknowledged message id
- Results: per task, outcome and SHA
- Decisions the user made (also written to Rela, per the gate's write-back rules), incidents and their workarounds
- Each in-flight task's Rela baseline snapshot line

## Hard-won rules

- One waiter. A second fails, or worse, steals messages.
- Write wrapper scripts to files and test them on a sample before relying on them. A quoting bug in an inline parser can silently eat a delivery.
- Watch host memory. N task workers + a deploy worker + you is N+2 agent sessions plus N validation runs. `agent-capacity.sh` accounts for that; trust it over a fixed number.
- A slot spent deploying is a slot not implementing. That is why deploys are delegated.
- Code that the deploy pipeline itself runs (the deployer, cron definitions outside the app tree) is usually not redeployed by a normal deploy. The profile should list these and the manual step each needs.
