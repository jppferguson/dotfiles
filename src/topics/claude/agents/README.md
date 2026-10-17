# Claude subagents

Subagent definitions symlinked to `~/.claude/agents/`. Each agent needs a reason to exist beyond a built-in or a skill, an explicit `model:`, and only current Claude Code tool names in `tools:`.

| Agent | Model | Why it exists |
| --- | --- | --- |
| `markdown-cleaner` | haiku | Cheap bulk markdownlint and British English cleanup across many files, which no built-in skill covers |

## Retired

- `code-reviewer`: duplicated the built-in `/code-review` skill, and had write tools it never needed.
- `gemini-code-reviewer`: no invocations on either Mac since 2026-09-18, and it overlapped `/code-review` and the `skill-codex` plugin.
- `post-change-validator`: replaced by the global instruction in `AGENTS.md` to run the project's own validate script.
