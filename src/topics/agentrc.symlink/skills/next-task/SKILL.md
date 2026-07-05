---
name: next-task
description: Pick up the next highest-priority task from doto for the current project, work it end to end (implement, validate, Codex review), and hand it off for review. Use when the user says "next task", "/next-task", "pick up the next ticket" or similar, in any project wired to doto.
---

# next-task

Work the next doto ticket for this project end to end and hand it off for review.

## Step 0: Resolve the doto project

Find the doto project ID for the current repository, in this order:

1. An argument passed to the skill (a doto project ID or project name)
2. A `doto` entry in the project's `CLAUDE.local.md`, `CLAUDE.md` or `AGENTS.md` (look for a line like `doto project: <id>`)
3. A project-level command or skill that already embeds the ID (e.g. `.claude/commands/next.md`) - if one exists, follow that file instead of this generic flow, since it may carry project-specific steps
4. Ask doto: list projects via the doto MCP tools and match against the repository name. Confirm the match with the user before proceeding.

Use the actor `agent:claude-code` for all doto calls.

## Step 1: Pick the next task

Call `mcp__doto__pick_next_task` scoped to the resolved project. If no eligible task is found, stop and tell the user there is nothing to pick up. Do not invent work.

Read the returned task carefully: acceptance criteria, type (task/bug/exploration/spike/research), blocking links, open sub-tasks. Briefly summarise which task you picked, then continue automatically unless the task is ambiguous or needs product decisions.

## Step 2: Move it to in_progress

Call `mcp__doto__start_task` before writing any code. If the lease is rejected (409: another process holds it), stop and report that the task is already being worked.

## Step 3: Do the work

- Detect the package manager from the lockfile and use it consistently.
- Match existing patterns in the area you are touching; use project skills when one fits.
- Keep changes scoped to the task. Surface anything larger rather than expanding silently.
- Add or update tests where the acceptance criteria imply verification.
- If the task is blocked, under-specified or wrong, stop and report back (optionally `mcp__doto__add_comment` or `mcp__doto__block_task`) rather than guessing.

## Step 4: Validate

Run the project's validation suite and fix what it surfaces:

- Prefer a dedicated script (`validate`) if `package.json` defines one
- Otherwise run the lint, type-check and test scripts that exist

Repeat until it passes. Never proceed to review with failing validation. If failures are outside the task's scope, stop and report them.

## Step 5: Codex review

If the `codex` CLI is available, run an automated review of the working-tree diff in read-only mode:

```bash
codex exec --skip-git-repo-check -m gpt-5.4 --config model_reasoning_effort="high" --sandbox read-only "Review the current git diff for this task. Focus on correctness bugs, security issues, missed edge cases, and deviations from the repo conventions. Be concise and list concrete, actionable findings only - no praise or restating the diff." 2>/dev/null
```

Treat Codex as a peer reviewer, not an authority: fix valid findings and re-validate; note why rejected findings were skipped. If Codex fails to run, report that and continue - do not block the hand-off on tooling failure.

## Step 6: Check off acceptance criteria

Use `mcp__doto__check_ac_batch` (`changedBy: agent:claude-code`). Only check criteria that are genuinely met; leave unmet ones unchecked and explain why in the review comment.

## Step 7: Hand off for review

Call `mcp__doto__submit_for_review` with a concise completion summary: what changed, which files, how it was verified, what the reviewer should focus on, any unmet criteria. For exploration/spike/research tasks also pass `findings` and a `decision`.

The human gate stays: a human signs off review to done.

## Step 8: Report

Summarise: task picked (title + id, now in review), what was implemented, files changed, validation result, Codex findings and how each was handled, criteria checked/unchecked, follow-ups or risks.

## Rules

- Always move to in_progress before changing code; always end in review. Never leave a task half-transitioned.
- Do not commit or push unless the user explicitly asks. This skill implements and hands off; it does not ship.
- Never check off acceptance criteria you have not actually satisfied.
