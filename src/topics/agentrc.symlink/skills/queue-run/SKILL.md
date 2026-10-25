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

- **Worker count:** what the user asked for. Default 3. Each worker is a full agent session, so check host memory before going above 4.
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

**Conditional GO for live-host work.** If the task touches something running on the host (launchd/systemd jobs, a reverse-proxy config, process killers, cron definitions, credentials), make the GO conditional: the worker must confirm that no committed test can reach the real thing (stubs injected by absolute path or environment, not PATH order alone) and that its own testing left the live config unchanged. Check it yourself after the ship.

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
- Decisions the user made, incidents and their workarounds

## Hard-won rules

- One waiter. A second fails, or worse, steals messages.
- Write wrapper scripts to files and test them on a sample before relying on them. A quoting bug in an inline parser can silently eat a delivery.
- Watch host memory. N task workers + a deploy worker + you is N+2 agent sessions; on a 16 GB machine, 4 task workers is about the limit.
- A slot spent deploying is a slot not implementing. That is why deploys are delegated.
- Code that the deploy pipeline itself runs (the deployer, cron definitions outside the app tree) is usually not redeployed by a normal deploy. The profile should list these and the manual step each needs.
