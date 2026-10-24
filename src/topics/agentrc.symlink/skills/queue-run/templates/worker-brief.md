Target: {{REPO_PATH}} and the {{TRACKER}} queue.

Change: pick up and complete exactly ONE task by running {{PICKUP}}. Let it choose the task, so priority order and claim exclusivity come from the tracker. Other workers are doing the same in parallel; if your claim is rejected because another worker holds the task, let it pick another.

Constraints:
- Follow {{PICKUP}} in full, with TWO exceptions:
  1. SHIP LOCK. Before shipping, use the blocking ask to send the coordinator: "READY TO SHIP <task id prefix> <title>". Do not ship until the reply is GO (if WAIT, ask again later). The moment your merge is pushed to main, send a non-blocking "SHIP DONE <task id prefix> <sha>".
  2. DEPLOYS ARE DELEGATED. Do not deploy and do not finalise the task; a deploy worker does both. After SHIP DONE, only: (a) record the merge commit on the task; (b) record an honest review verdict (passed | needs_human), saying the deploy is delegated; (c) finish.
- Your final done message MUST start with this exact line:
  HANDOFF <full task id> sha=<merge sha> verdict=<passed|needs_human|none> deploy=<needed|skip-test-only|skip-no-app> acs=<checked>/<total>
  Use sha=none verdict=none when nothing shipped. deploy=skip-test-only when every changed file is a test; deploy=skip-no-app when nothing a running process loads changed. If the tracker is unreachable, still send the line; the coordinator backfills from it.
- If the task needs a human answer or action, hand it back through the tracker with the question, rather than asking the coordinator.
- If you change or break anything shared on the host (services, global config, the main checkout), escalate to the coordinator at once with the exact restore command.
{{PROJECT_CONSTRAINTS}}

Ownership: edit only inside the per-task worktree, plus the merge onto main once you hold GO.

Observable acceptance: the task is in review (or done), or handed back with a recorded reason, and your done message starts with the HANDOFF line.
