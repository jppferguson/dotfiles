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
- `vendor/` - External dependencies

### Topic Organisation

Each topic directory can contain:

- `*.symlink` - Files symlinked to $HOME (without extension)
- `*.zsh` - Automatically sourced by ZSH
- `path.zsh` - Loaded first to setup PATH
- `completion.zsh` - Loaded last for autocomplete
- `install.sh` - Topic-specific installation script
- `update.sh` - Topic-specific update script

### Key Topics

- `zsh/` - ZSH configuration with Prezto framework
- `git/` - Git configuration and custom commands
- `homebrew/` - Brewfile for package management
- `macos/` - macOS defaults in YAML format
- `vs-code/` - VS Code settings and keybindings
- `node/` - Node.js configuration and global packages
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

# Install specific topic configuration
dot install {topic}
# Example: dot install node
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
- Keep personal notes in `___NOTES.md`
- Leave shared docs under the repo root

## Testing Guidelines

- Tests are written using Bats (Bash Automated Testing System)
- Author behavioural tests in Bats under `test/`
- Mirror the function under test (e.g., `functions.bats` for `src/functions/general`)
- Follow the `@test "function(): does thing"` pattern
- Remove `skip` guards once a scenario is implemented
- Always run `dot test` before opening a PR
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
- **Node.js**: asdf version manager (Node.js 23.1.0)
- **Updates**: topgrade updates all package managers at once

## Security & Configuration

- Treat dotfiles as public: never commit secrets or machine-specific tokens
- Use `~/.localrc` for local machine-specific configuration (not in git)
- When modifying Claude assets under `src/topics/claude/`, finish by running `dot claude sync`
- Review `zsh/zshrc.symlink` updates carefully—call out any path changes in PRs
- Keep shared documentation under the repository root and reserve `___NOTES.md` for personal scratch notes.

## Git Workflow & Conventions

### Commit Guidelines

- Keep commits focused and message them in imperative mood (`Add upgrade alias`, `Refine tskr`)
- Reference related issues in the body if applicable
- PRs should summarize the change, note any config migrations, and include verification steps (`dot test`, `dot symlink`, `dot claude sync`, etc.)

### Custom Git Commands

The repository includes many custom git commands in `src/topics/git/`:

- `git-all` - Operations on all repos in a directory
- `git-amend` - Amend commits
- `git-nuke` - Remove branches
- `git-track` - Track remote branches

## Shell Environment

Uses ZSH with Prezto framework. Key files:

- `zsh/zshrc.symlink` - Main ZSH configuration
- `zsh/zpreztorc.symlink` - Prezto configuration
- Files are loaded in this order: path.zsh → *.zsh → completion.zsh

## Important Files

- `~/.localrc` - Local machine-specific configuration (not in git)
- `src/bin/dot` - Main utility command for managing dotfiles
- `src/script/bootstrap` - Main setup script that creates symlinks
- `src/topics/homebrew/Brewfile.symlink` - Package definitions
- `src/topics/macos/defaults/` - macOS system settings configuration

## Adding New Configurations

1. Create a new topic directory: `mkdir src/topics/newtopic`
2. Add configuration files with `.symlink` extension
3. Run `dot symlink` to create symlinks
4. Add any topic-specific scripts (install.sh, update.sh)
5. Test with `dot test`

## Agent Integration Pattern

- Add the marker `<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->` near the top of each agent file so automation can discover the shared guidance.
- Link to `[AGENT_CONTEXT.md](./AGENT_CONTEXT.md)` within agent docs for easy human navigation.
- Keep agent-specific nuances (editor setup, tooling differences, prompt guidance) in their dedicated files while updating this context for anything shared across agents.
