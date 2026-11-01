Target: {{REPO_PATH}} and the {{TRACKER}} queue.

Change: pick up and complete exactly ONE task by running {{PICKUP}}. Let it choose the task, so priority order and claim exclusivity come from the tracker. Other workers are doing the same in parallel; if your claim is rejected because another worker holds the task, let it pick another.

Constraints:

- Follow {{PICKUP}} in full, with TWO exceptions:
  1. SHIP LOCK. Before shipping:
     - Rebase onto the current {{BASE_BRANCH}} and rerun your checks. Then compare `git diff --numstat {{BASE_BRANCH}}...HEAD` with `git diff --numstat {{BASE_BRANCH}} HEAD`. If they differ, your base is stale and a merge would revert someone else's commit, so rebase again.
     - Use the blocking ask to send the coordinator "READY TO SHIP <task id prefix> <title>", with your head sha and both numstats. Then WAIT for the reply in a blocking poll. Do not end your turn or go idle while you wait, because an idle notice crosses the reply and doubles every message.
     - Ship only when the reply is GO, and only when that GO names your current head sha. If you have committed since, ask again. If the reply is WAIT, ask again later.
     - The moment your merge is pushed to {{BASE_BRANCH}}, send a non-blocking "SHIP DONE <task id prefix> <sha>".
     - A repeated GO for work you have already shipped is a no-op: reply once with the same SHIP DONE line and nothing else.
     - Instructions in a GO, such as "don't finalise" or "rebase first", override this brief.
  2. DEPLOYS ARE DELEGATED. Do not deploy and do not finalise the task; a deploy worker does both. After SHIP DONE, only: (a) record the merge commit on the task; (b) record an honest review verdict with `mcp__doto__complete_ai_review` (verdict `passed` or `needs_human`, a summary of every cross-model review pass and how each finding was handled, and that the deploy is delegated) while the task is still in review. This call sets the task's AI-reviewed tag; a review comment alone does not. Call it after `submit_for_review`, because it refuses tasks that aren't in review; (c) finish.
- Your final done message MUST start with this exact line:
  HANDOFF <full task id> sha=<merge sha> verdict=<passed|needs_human|none> deploy=<needed|skip-test-only|skip-no-app> acs=<checked>/<total>
  Use sha=none verdict=none when nothing shipped. deploy=skip-test-only when every changed file is a test; deploy=skip-no-app when nothing a running process loads changed. If the tracker is unreachable, still send the line; the coordinator backfills from it.
- Bug tasks: reproduce the reported failure against real data or the real runtime before you fix it. If you cannot reproduce it, say so plainly in READY TO SHIP and give the evidence for your root cause. A cause inferred from reading code alone is a hypothesis, not a finding.
- If the task needs a human answer or action, hand it back through the tracker with the question, rather than asking the coordinator.
- If you change or break anything shared on the host (services, global config, the main checkout), escalate to the coordinator at once with the exact restore command.

{{PROJECT_CONSTRAINTS}}

Ownership: edit only inside the per-task worktree, plus the merge onto {{BASE_BRANCH}} once you hold GO.

Observable acceptance: the task is in review (or done), or handed back with a recorded reason, and your done message starts with the HANDOFF line.
