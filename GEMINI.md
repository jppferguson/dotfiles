# Gemini Project: Dotfiles

<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->

This file provides Gemini-specific guidance. General project context and shared guidelines are in [AGENT_CONTEXT.md](./AGENT_CONTEXT.md).

## Gemini-Specific Configuration

- Global instructions come from `~/.gemini/GEMINI.md`, which `src/topics/claude/install.sh` symlinks to `src/topics/agentrc.symlink/AGENTS.md` when `~/.gemini` exists. Edit the shared file in the repo, not the link.
- Treat `AGENT_CONTEXT.md` as the canonical source for structure, commands, style and testing expectations, and update it first when adding repo-wide guidance.
- Run `dot validate` before presenting work as done.
