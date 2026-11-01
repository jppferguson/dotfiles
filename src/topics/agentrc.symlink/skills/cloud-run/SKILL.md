---
name: cloud-run
description: Run self-contained doto tasks in Claude Code cloud sessions from a Mac. Finds, tags and reserves cloud-fit tasks, launches one cloud session per task with a single self-contained prompt (`claude --cloud` as a child process), watches for the finished branch, reviews it locally (diff gate, validate, Codex review, AC check), opens the PR, and writes a retro after every run so the process improves straight away. Use when the user says "cloud-run", "/cloud-run", "send this to the cloud", "launch cloud agents", "review the cloud branch" or "cloud retro", in a project wired to doto that has a `## Cloud runs` section in AGENTS.md.
---

# cloud-run

A cloud session gets one prompt and gets on with it:

- It can't ask questions or reach doto.
- It clones from GitHub, so it only sees what is pushed to the base branch (resolved as in `next-task` Step 0; `<base>` below).
- It doesn't load `~/.claude` or `~/.agentrc`.

So everything it needs goes in the repo and in its prompt. Its deliverable is one pushed branch ending in a `cloud: report` commit. The Mac does the review, the PR, every doto write and the retro.

This mirrors the personal-os flow (`~/Development/Personal/personal-os/docs/cloud-sessions.md`), which has its own project commands and pilot findings. Keep the comment formats the same, so both projects read alike.

Subcommands: `candidates`, `launch`, `status`, `review`, `retro`, `smoke`. With no subcommand, run `status` and suggest the next useful step.

## Step 0: Project setup

- Read the project's `AGENTS.md`. It needs a `doto project:` line and a `## Cloud runs` section naming:
  - the worker doc
  - the setup doc
  - the retro log
  - the fit criteria
- The repo also needs `.agents/cloud/protected-paths`.
- If either is missing, stop and offer to add them, modelled on 24-nights.
- Actors:
  - `agent:claude-code` for comments and edits
  - `agent:cloud` for claiming and returning the task (`start_task`, `return_task_to_todo`), because the reservation only lets that actor in
- Scripts in `~/.agentrc/scripts/`:
  - `cloud-launch.sh` starts a session
  - `watch-cloud-branch.sh` detects the finish
  - `check-cloud-diff.mjs` is the untrusted-diff gate

## candidates

1. Search the project's `todo` and `backlog` tasks:
   - `fully_ai` or `hybrid`
   - effort xs, s or m
   - not already tagged `cloud`

   Read each in full, with its blocking links.
2. Judge each against the fit criteria in `AGENTS.md`. Common failures:
   - needs a device, a real secret or a dashboard
   - visual judgement is the main AC
   - it shares files with in-flight work
   - its blocker won't land in time to matter
3. Show a table of task, verdict and reason. Include tasks that fit once a named blocker lands. Where a task almost fits, suggest a split: the cloud part is pure code and tests, the local part is the device and dashboard steps.
4. For each task the user agrees to:
   - add the tag `cloud`, keeping the existing tags
   - `reserve_task` with `reservedFor: "agent:cloud"`

   The tag identifies cloud work. The reservation is what actually stops local workers and the auto-pickup loop taking the task. Never approve tasks.

## launch [task ids | --next N]

1. **Preflight:**
   - `git status` and `git log origin/<base>..<base>` in the main checkout. The session sees only what is pushed to `<base>`. Unpushed or uncommitted changes to `AGENTS.md`, the worker doc or `.agents/cloud/` mean stop and say so.
   - Count live runs: tasks tagged `cloud` with a newest `CLOUD_DISPATCH` comment and no later `CLOUD_CLOSED`. The default cap is 3 at once across both Macs, because cloud usage comes out of the same plan. Use the user's number if they gave one.
2. **Check each task:**
   - tagged `cloud`, reserved for `agent:cloud`, status `todo`, `refinementStatus` `approved`
   - no open blocking link
   - the Rela drift check (`~/.agentrc/references/rela-gate.md`) is clean against its snapshot

   Skip any that fail, with the reason. `--next N` takes the first N that pass, ordered by due date then priority.
3. **Write the prompt.** Render `templates/prompt.md` into the scratchpad as `cloud-prompt-<id8>.md`:
   - `{{BASE_BRANCH}}` is `<base>`.
   - `{{BRANCH}}` is `cloud/<id8>-<slug>`, with a three or four word slug from the title. A re-run appends `-r2`, `-r3`.
   - `{{START_FROM}}` is `origin/<base>` on attempt 1. On a re-run it's the previous attempt's branch at its last gated SHA, so earlier work isn't lost. The rework notes then say what to keep and what to redo.
   - The description, ACs and requirements go in verbatim, never paraphrased.
   - `{{BLOCKERS_DONE}}` lists each done blocker's title and the files it added, from `git log --stat` on `<base>`.
   - `{{LAUNCH_NOTES}}` holds retro lessons that apply to this task and, on a re-run, the latest `CLOUD_REWORK` instructions. Otherwise it's "None".
   - No child, personal or client data, and no secrets.
   - Read it back once and ask: could a capable engineer new to this project do the task from this and the repo alone?
4. **Claim, then launch:**
   - Call `start_task` as `agent:cloud`. The lease will lapse, because nothing refreshes it, but the reservation still keeps every other agent out.
   - Run `~/.agentrc/scripts/cloud-launch.sh <prompt file>` from the repo root. It prints `SESSION <id> <url>`. To pin the model, set `CLOUD_MODEL=<model>`; if the launcher rejects it, drop it and note that in the retro.
   - If the launch fails, call `return_task_to_todo` as `agent:cloud`, then reserve the task again, and report.
5. **Record:** add one comment to the task, in this format:

   ```text
   CLOUD_DISPATCH
   session: <url>
   branch: <branch>
   attempt: <n>
   launched: <ISO time> from <hostname>
   prompt: <scratchpad path> (sha256 <first 12>)
   ```

6. **Watch:** start `~/.agentrc/scripts/watch-cloud-branch.sh <branch> 90` in the background. When it exits, run `review` on exit 0. On exit 2 or 3, report and suggest a nudge. If this conversation ends first, `status` on either Mac picks the run up from doto.
7. **Report:** each launched task with its session URL. The user can watch or nudge it at that URL or in the Claude app.

## status

For every live run (a `CLOUD_DISPATCH` with no later `CLOUD_CLOSED`):

1. `git ls-remote --heads origin <branch>`, and if the branch exists, read its tip subject.
2. Classify the run:
   - **running:** no branch yet, or no report commit yet
   - **done:** the tip is `cloud: report`. Read the report with `git log -1 --format=%B origin/<branch>`. If it says `BLOCKED`, show the reason.
   - **in review:** a PR exists (`gh pr list --head <branch>`)
   - **stale:** nothing pushed for more than 2 hours. Suggest a nudge: `claude -p "<message>" --cloud <session id> --output-format json`

Show a short table and suggest the next action for each run.

## review <task id | branch>

The branch is untrusted contractor output until it passes the gate.

1. **Fetch and gate**, before running anything from the branch:

   ```bash
   git fetch origin <branch>
   node ~/.agentrc/scripts/check-cloud-diff.mjs <branch> --base origin/<base>
   ```

   - Any `FAIL` stops the review: write a `CLOUD_REWORK` with the evidence. The only exception is a protected path an AC names explicitly; re-run with `--allow <path>` and note it in the review.
   - Read every `WARN`. New dependencies need a reason in the report.
   - On `PASS`, the gate prints `GATED <sha>`. From here on, use that SHA, never the branch name: the session can push again at any time.
2. **Read the report.** Compare its AC claims with the task's ACs, and note its decisions and "Needs the Mac" items.
3. **Validate in a worktree:**

   ```bash
   git worktree add --detach ../<repo>-cloud-<id8> <gated sha>
   ```

   Run `pnpm install --frozen-lockfile` and `pnpm validate` there, never in the main checkout.
4. **Codex review.** Claude wrote the diff, so Codex reviews it. Run `~/.agentrc/scripts/check-codex-review-model.sh` first, then:

   ```bash
   codex exec --skip-git-repo-check -p review --sandbox read-only "$(cat .github/review-prompt.md) Compare <gated sha> against origin/<base>." < /dev/null
   ```

5. **Check every AC yourself** against the diff and the tests; don't trust the report's ticks. For visible changes, check the committed screenshots against the UI review checklist. Run the app screens the report listed under "Needs the Mac" if a simulator is available, or list them for Jamie.
6. **Decide:**
   - **Fixes needed:** write a `CLOUD_REWORK` comment: attempt, findings with evidence, and numbered instructions. When the branch needs `<base>`, the instruction is to merge `origin/<base>` into it, never to rebase or force-push: the Mac gates each round by SHA. Then pick one:
     - The session is under about 2 hours old: send the instructions to it with `claude -p "<instructions>" --cloud <session id> --output-format json`, and ask for a new `cloud: report` commit at the end. Then watch again, passing the old report's SHA as the third argument so it doesn't count as done.
     - Otherwise, or after two cloud rounds: either relaunch as attempt n+1 with the rework in `{{LAUNCH_NOTES}}`, or fix it in the worktree, commit on the branch and push. Small fixes go on the Mac.
   - **Clean:**
     - Check that `git ls-remote origin <branch>` still points at the gated SHA. If the session pushed again, gate and review the new SHA first.
     - Land it the way the project's `## Shipping` section says, with this Mac review standing in for the local cross-model review. Check first whether that section has paused pull requests.
     - **PRs in use:** open the PR from the Mac with `gh pr create --head <branch> --base <base>`. The body is the report plus the Codex findings and how each was handled, and it links the doto task. Post the Mac's Codex review as a PR comment headed `## Codex review (local)`: every pass, each finding and how it was handled. When the GitHub review jobs have commented, read them before telling the user the PR is ready, and fix valid findings on the branch in one round. `requiresHumanReview: true` means Jamie merges the PR. `false` means the Mac may squash-merge the gated SHA, but only when the user asked to ship.
     - **PRs paused:** no PR and no GitHub review jobs. Put the Codex review (every pass, each finding and how it was handled) in the doto review comment instead. Squash-merge the gated SHA onto `<base>` only when the user asked to ship, whatever the review flag, and leave `requiresHumanReview: true` tasks in review for the human.
     - `submit_for_review` with the PR link or merge SHA, the fresh Rela snapshot, and the two sections next-task Step 7 requires (acceptance criteria with evidence, cross-model review).
     - Straight after, `check_ac_batch` every AC you verified yourself in step 5 (the `agent:cloud` lease blocks it before the submit). Never leave an agent-verifiable AC for the human.
     - Write `CLOUD_CLOSED` with `outcome: reviewed`, the PR URL (or the merge SHA), the rework round count and a `gate:` line copying the gate's PASS line and any WARN lines, so the retro has them.
   - **Abandon** (wrong approach, or too big to fix):
     - Write `CLOUD_CLOSED` with `outcome: handed_back` and the reason.
     - Call `return_task_to_todo` as `agent:cloud`, which clears the reservation.
     - Reserve it again only if it should go back to the cloud. Usually it should be split first.
7. **Clean up:** `git worktree remove` the worktree. Cloud sessions can't delete branches, so delete a closed run's remote branch from the Mac once its PR is merged or it's abandoned.
8. Go straight on to `retro`.

## retro <task id>

Run this after every review, while the detail is fresh. The aim is to change something before the next launch, not to write an essay.

1. **Gather:**
   - the launch time (`CLOUD_DISPATCH`) and the report commit time
   - the number of rework rounds
   - gate warnings and failures
   - Codex and PR review findings, grouped by `review-prompt.md` item
   - `pnpm validate` failures the cloud run missed
   - the report's "Retro notes" and "Decisions made without asking"
   - anything the user said about the result
2. **Find the cause** of each problem. It's one of:
   - the prompt template
   - the worker doc
   - the task's refinement
   - the environment
   - the fit criteria
   - the gate
3. **Act now.** Change the file each fixable cause points to, in this pass:
   - `templates/prompt.md`
   - the project's `docs/agents/` docs or `.agents/cloud/protected-paths`
   - the fit criteria or the refinement rules in `AGENTS.md`
   - the setup doc. Also tell the user what to change at claude.ai/code.
   - a waiting sibling task's ACs

   Anything you can't fix now becomes a doto task tagged `process`.
4. **Write it up.** Add the entry at the top of the project's retro log using its template, update the totals, and list each action with the file it changed.
5. **Hand back.** Tell the user the two or three changes that matter most, and offer to commit and push them. Repo changes must be on `<base>` before the next launch, or the next session won't see them.

Every fifth retro, read the last five together and write any patterns into the log. For example:

- which kinds of task fit the cloud
- the average number of rework rounds
- whether the cap or the fit criteria should change

## smoke

Check that the environment works. It changes nothing in the repo:

- Launch a prompt asking the session to report:
  - `node --version`, `pnpm --version` and `gh auth status`
  - `git ls-remote origin <base>`
  - whether `docker info` works
  - any doto or Rela tools it can see

  It must not commit or push.
- Give the user the URL to read the answer. Cloud transcripts can't be read from the CLI.

## Rules

- Launch only approved tasks that are tagged `cloud`, reserved for `agent:cloud` and unblocked.
- Never run code from a cloud branch before the diff gate passes.
- Never merge a cloud PR except as `## Shipping` allows (the review flag is false and the user asked to ship), and only at the gated SHA.
- No child, personal or client data, or secrets, in a prompt, a follow-up, a report, a PR or a retro.
- Stay within the cap on concurrent sessions.
- Every review ends with a retro.
