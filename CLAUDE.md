# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository based on Holman's dotfiles pattern. It uses a topic-based organisation where configuration files are grouped by application/topic in the `src/topics/` directory.

## Key Commands

### Development Commands

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

## Architecture

### Directory Structure

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

## Testing

Tests are written using Bats (Bash Automated Testing System):

```bash
# Run all tests
dot test

# Run specific test file
bats test/functions.bats
```

## Adding New Configurations

1. Create a new topic directory: `mkdir src/topics/newtopic`
2. Add configuration files with `.symlink` extension
3. Run `dot symlink` to create symlinks
4. Add any topic-specific scripts (install.sh, update.sh)

## Package Management

- **Primary**: Homebrew (see Brewfile.symlink)
- **Node.js**: asdf version manager (Node.js 23.1.0)
- **Updates**: topgrade updates all package managers at once

## Important Files

- `~/.localrc` - Local machine-specific configuration (not in git)
- `src/bin/dot` - Main utility command for managing dotfiles
- `src/script/bootstrap` - Main setup script that creates symlinks

## Git Workflow

The repository includes many custom git commands in `src/topics/git/`:

- `git-all` - Operations on all repos in a directory
- `git-amend` - Amend commits
- `git-nuke` - Remove branches
- `git-track` - Track remote branches

## Shell Environment

Uses ZSH with Prezto framework. Key files:

- `zsh/zshrc.symlink` - Main ZSH configuration
- `zsh/zpreztorc.symlink` - Prezto configuration
- Files are loaded in this order: path.zsh → \*.zsh → completion.zsh
