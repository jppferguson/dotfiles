---
name: next-task
description: Pick up the next highest-priority task from doto for the current project, check the Rela direction has not moved, work it end to end (implement, validate, cross-model review), and hand it off for review, shipping it only when asked (--ship). Use when the user says "next", "next task", "/next-task", "pick up the next ticket" or similar, in any project wired to doto.
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

Then resolve the **base branch**, the branch work lands on, in this order:

1. A `Base branch:` line in the project's `AGENTS.md` or `CLAUDE.md`
2. The repository's default branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
3. `main`

Wherever this skill says "the base branch", use that name. A project whose production branch differs from its base branch (for example `develop` for work, `main` for production) never has `main` pushed by this skill.

## Step 1: Pick the next task

Call `mcp__doto__pick_next_task` scoped to the resolved project. If no eligible task is found, stop and tell the user there is nothing to pick up. Do not invent work.

Before picking, build `excludeTaskIds`, unless the user named the task:

- Tasks tagged `cloud`. They're reserved for cloud sessions (the `cloud-run` skill).
- With `--lane <name>` (passed by a `queue-run` coordinator, or by the user): tasks tagged with any other lane, such as `lane:mini` when you are `lane:mbp`. Your own lane's tasks and untagged tasks stay in the pool. Lanes are soft: they keep two machines out of the same files, and the lease, not the lane, is what stops two workers taking one task.

Search the project by those tags (`search_tasks` with `tags`, status `todo`) and pass the IDs.

Read the returned task carefully: acceptance criteria, type (task/bug/exploration/spike/research), blocking links, open sub-tasks. Briefly summarise which task you picked, then continue automatically unless the task is ambiguous or needs product decisions.

## Step 1b: Check the direction has not moved

Run the drift check in `~/.agentrc/references/rela-gate.md` against the task's `Rela snapshot:` line (written by the `refine` skill). If a relevant decision has landed or a relevant brief proposal is open, follow the gate's outcome: fix a small, unambiguous mismatch in the task first, otherwise comment, release the reservation (`release_reservation`) and pick the next task. Keep the fresh snapshot for Step 6b.

## Step 2: Move it to in_progress

Call `mcp__doto__start_task` before writing any code. If the lease is rejected (409: another process holds it), stop and report that the task is already being worked.

Keep the lease alive while you work: call `mcp__doto__refresh_lease` after each commit and before and after every `pnpm validate` or other run longer than a few minutes. A task left `in_progress` with a dead lease and no commits looks abandoned, and a coordinator on either machine may hand it back.

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

## Step 5: Cross-model review

The reviewer is always the other model family, and uses the project's own review prompt (for example `.github/review-prompt.md`) when there is one, otherwise the generic prompt below. When Codex is running this skill, review with `claude -p --permission-mode plan`. When Claude is running it and the `codex` CLI is available, run an automated review of the working-tree diff in read-only mode:

```bash
~/.agentrc/scripts/check-codex-review-model.sh
codex exec --skip-git-repo-check -p review --sandbox read-only "Review the current git diff for this task. Focus on correctness bugs, security issues, missed edge cases, and deviations from the repo conventions. Be concise and list concrete, actionable findings only - no praise or restating the diff." < /dev/null 2>/dev/null
```

`-p review` loads `~/.codex/review.config.toml`, the single home for the review model and effort. Change them there, not here - pinning `-m` in each command is what left these call sites on the retired `gpt-5.4`. The check script (stderr, never blocks) reads Codex's own model list: it auto-updates the profile to OpenAI's named replacement for a retiring model or to a newer generation of the same tier (printing `UPDATED:`), and only warns when a change needs judgement, such as the tier disappearing. If it prints either, mention it in the final report so no model change goes unnoticed.

Treat Codex as a peer reviewer, not an authority: fix valid findings and re-validate; note why rejected findings were skipped. If Codex fails to run, report that and continue - do not block the hand-off on tooling failure.

## Step 6: Check off acceptance criteria

Use `mcp__doto__check_ac_batch` (`changedBy: agent:claude-code`). Only check criteria that are genuinely met; leave unmet ones unchecked and explain why in the review comment.

The human reviewer should find every criterion an agent can verify already checked. Before handing off:

- Verify each criterion yourself against the code, the tests and the output (name the test, the command or the file and line). Don't tick from memory or from another agent's report.
- If a criterion is mechanically checkable but not yet met, do the work or run the check now rather than leaving it for the reviewer.
- Leave unchecked only what genuinely needs a human (a sign-off, a device, a dashboard, a decision). Split a mixed criterion in the comment: say which part is met and which part is the human's.
- `check_ac_batch` can fail while another actor's lease is held (for example `agent:cloud`). Call it again straight after `submit_for_review`; never skip it.
- Never use `force` on `submit_for_review` to get past criteria you could have verified.

### Attaching evidence (screenshots, samples, logs)

Attach evidence files to the task rather than describing them. Pick the route by where the file is relative to doto:

- **Default, from any machine:** `~/.agentrc/scripts/doto-attach.sh <taskId> <file> [--comment <commentId>]`. It uploads the file straight from your machine with `curl`, so the bytes never enter the conversation, and it needs `DOTO_MCP_TOKEN` in the environment. Any path works (scratchpad, `$TMPDIR`, repo, worktree). It prints `attached <file> to <taskId>: <attachmentId>` and exits non-zero with a reason on failure. To attach under a comment, `add_comment` first and pass the returned id.
- **`upload_attachment_from_path`** only when the file is on the machine doto runs on (the Mac mini) and that machine's doto MCP is the one connected. It reads the path on the doto server, so from any other machine it fails with "not found" or "outside the allowed directories".
- **Never `upload_attachment`** for a screenshot or any non-trivial file: it puts the whole file into the tool call as base64 (tens of thousands of tokens per image).

## Step 6b: Re-check Rela

Run the drift check again against the snapshot from Step 1b. The direction can change while you work; do not hand off or ship work built on a decision that has since been reversed. Record any decision the user made during the task as the gate's **Write-back** section says.

## Step 7: Hand off for review

If the project's `## Shipping` section says PRs open automatically and the task follows the pull-request policy, open the PR first (Step 7b's pull-request steps, including the last drift check) without waiting to be asked, and include its link in the summary below. Merging and local pushes to the base branch still wait for `--ship`.

Call `mcp__doto__submit_for_review` with a concise completion summary: what changed, which files, how it was verified, what the reviewer should focus on, any unmet criteria. The summary always has two sections the reviewer can scan:

- **Acceptance criteria:** one line per criterion, met or not, with its evidence.
- **Cross-model review:** which reviewer ran (or why it couldn't), each finding, and whether it was fixed (with the commit) or rejected (with the reason). "No findings" is a result; say so.

When a PR is open, post the same cross-model review as a PR comment headed `## Codex review (local)` (or `## Claude review (local)` when Codex wrote it), so it sits next to the GitHub review jobs. Before telling anyone a PR is ready, read the GitHub review job comments on it and fix the valid findings in one round, as the project's PR rules describe. For exploration/spike/research tasks also pass `findings` and a `decision`. Include the gate's `Rela checked` note and fresh `Rela snapshot:` line.

Straight after the submit, call `mcp__doto__complete_ai_review` (`actor: agent:claude-code`):
- Verdict `passed`, or `needs_human` when any criterion only a person can check is open.
- The summary covers every cross-model review pass and how each finding was handled.
- This call sets the task's AI-reviewed tag; the review comment alone does not.
- It refuses a task that isn't in review, so do it before shipping or handing over. A human may move the task to done soon after.

The human gate stays: a human signs off review to done.

## Step 7b: Ship (only when asked)

Ship only when the user passed `--ship`, asked to ship in their own words, or a `queue-run` brief tells you to. Otherwise stop at Step 7. The one exception is a PR the project says opens automatically (Step 7).

Follow the project's `## Shipping` section in `AGENTS.md` (or `CLAUDE.md`). If there is none, ask the user how to ship rather than guessing. Typical policies:

- **Local merge:** commit on the task branch, rebase onto the base branch, rerun validation, squash-merge to the base branch and push. Never force-push. Another machine may push the base branch first. If the push is rejected as non-fast-forward, `git fetch`, rebase the squash commit onto `origin/<base branch>`, rerun validation and push again. After three rejections, stop and report instead of looping.
- **Pull request:** commit, push the branch and open a PR with `gh pr create --base <base branch>`, linking the doto task. Leave merging to the human.

Run the Rela drift check once more immediately before the merge or `gh pr create`; it is the last cheap moment to stop. Record the commit with `link_commit`.

## Step 8: Report

Summarise: task picked (title + id, now in review), what was implemented, files changed, validation result, the Rela checks and anything written back to Rela, how it shipped (if it did), reviewer findings and how each was handled, criteria checked/unchecked, follow-ups or risks.

## Rules

- Always move to in_progress before changing code; always end in review. Never leave a task half-transitioned.
- Do not commit or push except under Step 7b, or to open a PR the project says opens automatically. Without `--ship`, an explicit request or a queue-run brief, this skill implements and hands off; it does not merge or push the base branch.
- Never check off acceptance criteria you have not actually satisfied.
