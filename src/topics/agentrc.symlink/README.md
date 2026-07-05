# agentrc

Shared, agent-agnostic AI configuration. This directory is symlinked to `~/.agentrc` by the dotfiles bootstrap, so edits here are live immediately and every tweak is tracked in git.

Anything Claude-specific (settings.json, subagents, statusline) lives in `src/topics/claude/` instead. This directory holds only content any coding agent (Claude Code, Codex, Gemini, OpenCode) can use.

## Layout

- `AGENTS.md` - global instructions for all agents. Each agent loads it via a symlink created by the claude topic's `install.sh`:
  - `~/.claude/CLAUDE.md -> ~/.agentrc/AGENTS.md`
  - `~/.codex/AGENTS.md -> ~/.agentrc/AGENTS.md` (if Codex is installed)
  - `~/.gemini/GEMINI.md -> ~/.agentrc/AGENTS.md` (if Gemini is installed)
  - `~/.config/opencode/AGENTS.md -> ~/.agentrc/AGENTS.md` (if OpenCode is installed)
- `skills/` - global skills, one directory per skill with a `SKILL.md`. Symlinked to `~/.claude/skills`; other agents that support the skills format can point at the same directory.
  - `next-task` - work the next doto ticket end to end and hand off for review
  - `session-wrap` - end-of-session housekeeping (memory, skill suggestions, stale artifacts)
  - `init-agent-context` - set up the AGENT_CONTEXT.md cross-agent pattern in a project
- `standards/` - reference standards, read on demand rather than preloaded:
  - `code-style.md`, `markdown-style.md`, `tech-stack.md`, `best-practices.md`, `anti-ai-patterns.md`

## Principles

- **Lean always-on context**: `AGENTS.md` stays small (facts and behavioural rules only). Procedures go in `skills/`, reference material in `standards/`, both loaded on demand.
- **One source of truth**: no per-agent copies of shared content; agents get symlinks or thin shims.
- **Project overrides**: a project's own AGENT_CONTEXT.md / CLAUDE.md wins over these globals.

## History

This started as an Agentrc (based on [AgentOS](https://github.com/buildermethods/agent-os)) setup with a tskr task system. The AgentOS instruction flows and tskr commands were removed in July 2026 (task management moved to doto); see git history if anything needs resurrecting.
