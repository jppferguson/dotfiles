# Orchestrator adapters

Map the six primitives from `SKILL.md` onto the orchestrator in use. Add a section here when you run the protocol on a new one.

## Orca

Load the version-matched guide first: `orca skills get orchestration`.

| Primitive | Orca |
| --- | --- |
| `spawn(brief)` | `orca orchestration worker-start --spec "$(cat brief.md)" --worktree current --agent claude [--model <id>] --json`; the handle is the `ctx_...` dispatch id |
| `ask` | the worker preamble's blocking ask command |
| `reply` | `orca orchestration reply --run <run> --id <msg id> --body "..."` |
| `send` | `orca orchestration send --run <run> --to dispatch:<ctx> --subject ... --body ...` |
| `wait()` | `orca orchestration check --run <run> --ack <last delivery> --wait --types "worker_done,escalation,question,status" --timeout-ms 590000 --json`, run in the background |
| `release` | `orca orchestration worker-release --dispatch <ctx>` |

Notes:

- Only one active waiter per run (`waiter_exists`). "You have N orchestration messages" nudges do not need a second check while a waiter is running; if they repeat with no waiter wake-up, peek with `check --json` (no `--wait`): they are usually heartbeats, which you acknowledge with `--ack`.
- Output interleaves `_keepalive` lines with JSON objects. Parse with a streaming JSON decoder in a script file, not an inline one-liner.
- `--worktree current` puts every worker in the coordinator's checkout; the task workflow itself must create per-task worktrees.
- A finished worker's terminal can stay open (`user_owned`, `retained`). Releasing is still correct; the user can close the tab.
- `worker-read --dispatch <ctx> --source terminal` shows what a quiet worker is doing.

## Claude Code subagents (Agent tool)

| Primitive | Agent tool |
| --- | --- |
| `spawn(brief)` | `Agent` with the brief as `prompt`, `isolation: "worktree"` if it edits code, an explicit `model` |
| `ask` | not available: a subagent cannot block on the parent. Split the worker at the ship point: it ends with a `READY` report, you serialise, then resume it with `SendMessage` |
| `reply` / `send` | `SendMessage` to the agent's id |
| `wait()` | the harness notifies you when a background agent completes |
| `release` | implicit when the agent finishes |

Notes:

- Subagents cannot spawn subagents, so the deploy worker is a separate `Agent` call from the coordinator.
- Respect the session's concurrency budget (often three subagents at once).

## Other orchestrators

You need a way to start an agent with a brief, a message channel both ways, and a way to wait on that channel. If the orchestrator only has a shared task list (no messages), use files: the worker writes `ship-request-<task>` and polls for `ship-go-<task>`; HANDOFF lines go to `handoff/<task>.txt`; the coordinator watches the directory.
