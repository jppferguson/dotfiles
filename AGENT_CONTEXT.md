# Agent Context

This file provides shared context and guidance for all AI agents (Claude Code, Gemini, etc.) working with this repository. Agent-specific instructions remain in their respective files (CLAUDE.md, GEMINI.md, etc.).

## Repository Overview

This is a personal dotfiles repository based on Holman's dotfiles pattern. It uses a topic-based organisation where configuration files are grouped by application/topic in the `src/topics/` directory.

## Architecture & Directory Structure

- `src/bin/` - Custom commands added to PATH
- `src/functions/` - Shell functions loaded into environment
- `src/script/` - Installation and setup scripts
- `src/topics/` - Topic-based configurations (main organisation)
- `test/` - Bats tests for shell functions

### Topic contract

Each directory in `src/topics/<name>/` is a topic. These are the file names the loaders recognise; anything else is just a file. Create only what a topic needs, since a topic can be a single `path.zsh`.

| File | Read by | When it runs | Shell |
| --- | --- | --- | --- |
| `path.zsh` | `zsh/zshrc.symlink` | First of the zsh files, in alphabetical topic order (`zshrc.symlink` then re-asserts the asdf shims at the front of PATH) | zsh only |
| `*.zsh` (any other name) | `zsh/zshrc.symlink` | After every `path.zsh` and before the completions, in alphabetical order | zsh only |
| `completion.zsh` | `zsh/zshrc.symlink` | Last of the zsh files, after compinit | zsh only |
| `aliases.sh` | `loadAllAliases` in `src/functions/common`, called by `zsh/zshrc.symlink` and `bash/bash_profile.symlink` | At shell start, after the zsh files | zsh and bash; the only per-topic file bash reads, so use it for anything bash needs (bash also sources `~/.aliases` and `~/.functions`, linked from `bash/aliases.symlink` and `bash/functions.symlink`) |
| `<name>.symlink` file | `install_dotfiles()` in `src/script/bootstrap` | When `dot symlink` runs | Linked to `~/.<name>` (extension stripped) |
| `<name>.symlink` directory | `install_dotfiles()` | When `dot symlink` runs | Linked as a whole, e.g. `agentrc.symlink` to `~/.agentrc` and `hammerspoon/hammerspoon.symlink` to `~/.hammerspoon` |
| `.config/<tool>/<file>.symlink` | `install_dotfiles()` | When `dot symlink` runs | A path containing a `/` keeps its structure under `$HOME`, e.g. `ghostty/.config/ghostty/config.symlink` to `~/.config/ghostty/config`; parent directories are created |
| `install.sh` | `dot install <name>` (sourced), and `src/script/install` (offers every topic interactively, homebrew first; topics can be skipped for good via `DOTFILES_IGNORE` in `~/.localrc`) | One-off setup on a machine; must be safe to re-run | bash |
| `update.sh` | `src/script/update`, which runs every `update.sh` it finds (or those matching the names passed) | When that script is run by hand; `dot update` only runs topgrade, so a check that should run there is also registered in `topgrade.toml.symlink`'s `[commands]` block, as `vs-code` does | bash |

Topics do not have to supply both scripts. In the current tree:

- Many topics ship no install or update script, because the tool is installed elsewhere or the topic is only shell config: `bun` (`path.zsh`, `completion.zsh`), `pnpm`, `docker` and `kimi-code` (`path.zsh` only), `git` and `system` (aliases and shell config), `node`, `asdf`, `bash`, `zsh`.
- Install-only topics are never touched by an update: `agentrc.symlink`, `hammerspoon`, `herdr`, `php`, `z`.
- Topics with both scripts pair them: `claude`, `duti`, `fonts`, `homebrew`, `macos`, `prezto`, `vs-code`.
- No topic is update-only. `node` has `aliases.sh` and `huskyrc.symlink` but no scripts, so there is no `dot install node`; global npm packages are updated by topgrade.
- `set-*.sh` files (in `macos`) are helpers called from a topic's own scripts, except `set-dock.sh`, which `dot dock` sources directly, so changing it changes that command.

### Key Topics

- `zsh/` - ZSH configuration with Prezto framework
- `git/` - Git configuration and custom commands
- `homebrew/` - Brewfile for package management
- `macos/` - macOS defaults in YAML format
- `vs-code/` - VS Code settings and keybindings, plus the tracked extension list (`extensions.txt`, installed by `install.sh`, drift shown by `update.sh`)
- `node/` - Node.js aliases and the husky hook config
- `asdf/` - Version management for Node.js and other tools

## Key Commands & Workflows

### Development Commands

- Run `dot help` for a quick index of available subcommands and topics.
- Re-run `dot symlink` (or `./src/script/bootstrap`) whenever you add, rename, or remove `.symlink` files.
- `dot update` has an alias `dot upgrade`; use either before raising environment-related changes.

```bash
# Navigate to dotfiles directory
dot cd

# Run tests
dot test
# or directly:
bats test/*.bats

# Apply symlinks (after adding new *.symlink files)
dot symlink
# or directly:
./src/script/bootstrap

# Update all packages and tools
dot update
# or directly:
topgrade

# Reload shell configuration
dot reload
```

### Installation Commands

```bash
# Initial setup (creates all symlinks)
./src/script/bootstrap

# Install a topic that ships an install.sh (see the topic contract)
dot install {topic}
# Example: dot install prezto
```

### macOS-specific Commands

```bash
# Apply macOS system defaults
dot macos

# Apply Dock settings
dot dock

# Set default apps for file types
dot duti
```

## Development Conventions

### Code Style & Naming

- All scripts target Bash; start new files with `#!/usr/bin/env bash`
- Use two-space indentation, matching `src/bin/dot`
- Name shell functions in `snake_case`
- Keep topic directories lowercase (e.g., `src/topics/git`)
- When adding helpers, source them through `src/functions/`
- Gate external dependencies behind existence checks
- Annotate tricky logic with brief comments
- Add `# shellcheck` directives when sourcing relative paths

### File Organization

- **Always prefer editing existing files** over creating new ones
- Use topic-based organization for new configurations
- Files ending in `.zsh` auto-load into shell environment
- `.symlink` files map into `$HOME` when `dot symlink` runs
- Leave shared docs under the repo root

## Testing Guidelines

- Tests are written using Bats (Bash Automated Testing System)
- Author behavioural tests in Bats under `test/`
- Mirror the function under test (e.g., `functions.bats` for `src/functions/general`)
- Follow the `@test "function(): does thing"` pattern
- Remove `skip` guards once a scenario is implemented
- Always run `dot validate` (secrets, shellcheck, zsh syntax, markdown, tests) before opening a PR
- Extend coverage whenever introducing new shell utilities
- Capture terminal excerpts or screenshots when you touch interactive commands so reviewers can confirm UX changes.

```bash
# Run all tests
dot test

# Run specific test file
bats test/functions.bats
```

## Package Management

- **Primary**: Homebrew (see Brewfile.symlink)
- **Node.js and other runtimes**: managed by asdf; the versions are pinned per machine in `~/.tool-versions` (which differs between machines), so check that file rather than relying on a version written here
- **Updates**: topgrade updates all package managers at once; `topgrade.toml.symlink`'s `[commands]` block owns global npm package updates (`npm update --location global --force`) — `node/npm-global` and `node/update.sh` were removed as dead code, since `dot update` never called them

## Security & Configuration

- Treat dotfiles as public: never commit secrets or machine-specific tokens
- Use `~/.localrc` for local machine-specific configuration (not in git)
- Claude/agent assets are symlinked live: `~/.claude/*` items link into `src/topics/claude/` (except `~/.claude/settings.json`, a generated merge of `settings.json` and the gitignored `settings.local.json`, re-merged by a LaunchAgent rendered from `com.jppferguson.claude-settings-sync.plist.template`), and `~/.agentrc` links to `src/topics/agentrc.symlink/` (shared cross-agent config: AGENTS.md, skills, standards). Edits apply immediately; run `dot claude status` to verify link health, `dot claude sync` only to repair links
- Review `zsh/zshrc.symlink` updates carefully—call out any path changes in PRs
- Keep shared documentation under the repository root

## Git Workflow & Conventions

### Commit Guidelines

- Keep commits focused and message them in imperative mood (`Add upgrade alias`, `Fix zsh prompt`)
- Reference related issues in the body if applicable
- PRs should summarize the change, note any config migrations, and include verification steps (`dot test`, `dot symlink`, `dot claude status`, etc.)

### Custom Git Commands

The repository includes custom git commands in `src/bin/` (the `git-*` files there; `ls src/bin` is the source of truth), for example:

- `git-all` - Stage all unstaged files
- `git-amend` - Amend commits
- `git-nuke` - Remove branches locally and remotely
- `git-undo` - Undo the last commit

The `wt` and `wt-clean` worktree helpers are shell functions in `src/topics/git/worktree.zsh`.

## Shell Environment

Uses ZSH with Prezto framework. Key files:

- `zsh/zshrc.symlink` - Main ZSH configuration
- `zsh/zpreztorc.symlink` - Prezto configuration
- Files are loaded in this order: path.zsh → *.zsh → completion.zsh, then `aliases.sh` files via `loadAllAliases` (see the topic contract)

## Important Files

- `~/.localrc` - Local machine-specific configuration (not in git)
- `src/bin/dot` - Main utility command for managing dotfiles
- `src/script/bootstrap` - Main setup script that creates symlinks
- `src/topics/homebrew/Brewfile.symlink` - Package definitions
- `src/topics/macos/defaults/` - macOS system settings configuration

## Adding New Configurations

1. Create a new topic directory: `mkdir src/topics/newtopic`
2. Add the files the topic needs, using the names in the topic contract (`.symlink` files, `*.zsh`, `aliases.sh`)
3. Run `dot symlink` to create symlinks
4. Add `install.sh` and, if the topic needs maintenance, `update.sh`
5. Test with `dot validate`

## Agent Integration Pattern

- Add the marker `<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->` near the top of each agent file as a convention for pointing at the shared guidance (nothing in this repo reads it programmatically).
- Link to `[AGENT_CONTEXT.md](./AGENT_CONTEXT.md)` within agent docs for easy human navigation.
- Keep agent-specific nuances (editor setup, tooling differences, prompt guidance) in their dedicated files while updating this context for anything shared across agents.

## doto

doto project: 60ea0f2f-7c32-4563-b15d-5812a7eec3b3

Backlog: doto project `.dotfiles` - file findings there, not in a markdown list. One-off manual steps for physical machines live in [docs/machine-checklist.md](./docs/machine-checklist.md).
