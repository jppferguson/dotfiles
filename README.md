# Jamie ❤ ~/

Dotfiles are all those files beginning with a "." in your user directory and make your system (particularly anything to do with the command line) work and look the way you want it.

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/.dotfiles`).

The installation step requires the [XCode Command Line Tools](https://developer.apple.com/downloads), although you *should* be prompted to install these if you don't have them installed already.

### Backups

Fair warning: The bootstrap script *attempts* to backup existing dotfiles in your HOME directory, but to be safe you should probably make your own copy...

```sh
git clone https://github.com/jppferguson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
src/script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

`dot` is the main command for managing your dotfiles environment.
You can find this script in `src/bin/`. Run `dot help` to see all available commands.

### dot command reference

- **`dot cd`** - Navigate into the dotfiles directory
- **`dot clean`** - Clean up caches (brew)
- **`dot claude {cmd}`** - Manage Claude Code configuration (install|status|diff|sync|backup)
- **`dot dock`** - Apply macOS Dock settings
- **`dot duti`** - Set default apps for file types (UTI)
- **`dot edit`** - Open dotfiles in your IDE and Git GUI
- **`dot help`** - Show all available commands
- **`dot install {pkg}`** - Install a specific package/topic
- **`dot macos`** - Apply macOS system defaults
- **`dot reload`** - Reload shell configuration
- **`dot symlink`** - Re-run bootstrap to create/update symlinks
- **`dot symlink --prune [--yes]`** - List (or, with `--yes`, remove) dangling `$HOME` symlinks left by deleted topics
- **`dot test`** - Run tests
- **`dot update`** - Update all packages via topgrade
- **`dot upgrade`** - Alias for `dot update`
- **`dot validate`** - Run every check: gitleaks over the full history, shellcheck, zsh syntax, markdownlint and tests. A gitleaks pre-commit hook (`.githooks/`, enabled by `dot symlink`) blocks staged secrets

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/jppferguson/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md}
src/script/bootstrap
```

## Additional Commands

### Git Helpers

The repository includes several custom git commands in `src/bin/`:

- **`git-all`** - Stage all unstaged files
- **`git-amend`** - Amend commits easily
- **`git-copy-branch-name`** - Copy the current branch name to the clipboard
- **`git-nuke`** - Remove branches locally and remotely
- **`git-switcheroo`** - Switch a git remote between HTTPS and SSH
- **`git-undo`** - Undo the last commit
- **`git-unpushed`** - Show unpushed commits
- **`git-wtf`** - Show the current git status in detail
- **`wt`** (`src/topics/git/worktree.zsh`) - Create a git worktree and branch in a sibling `-worktrees` folder, then open it in `$EDITOR`
- **`wt-clean`** (`src/topics/git/worktree.zsh`) - Remove a worktree created by `wt` and delete its branch

### Other Utilities

Additional commands available in `src/bin/`:

- **`agrep`** - Search for strings across files in large websites
- **`claude-usage`** - Track Claude Code session usage against monthly limits
- **`e`** - Quick edit command
- **`gitgui`** - Open git GUI
- **`search`** - Search for files
- **`todo`** - Show TODO items in code

## Topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory under `src/topics/` and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `src/script/bootstrap`.
Anything named `aliases.sh` is picked up by `loadAllAliases` (`src/functions/common`) in both zsh and bash.

The recognised file names are listed under Components below; the "Topic contract" section of [AGENT_CONTEXT.md](AGENT_CONTEXT.md) has the full table of when each runs and which topics ship which scripts.

### Key Topics Included

- **asdf** - Version manager for Node.js, Ruby, and other tools
- **bash** - Bash shell configuration
- **docker** - Adds Docker Desktop CLI tools to PATH
- **duti** - Default application settings for file types on macOS
- **ghostty** - Ghostty terminal configuration
- **git** - Git configuration and custom commands
- **hammerspoon** - macOS automation and window management
- **herdr** - Herdr terminal workspace manager configuration
- **homebrew** - Package management via Brewfile
- **kimi-code** - Adds the Kimi Code CLI to PATH
- **macos** - macOS system defaults (YAML-based configuration)
- **node** - Node.js aliases and husky hook config
- **prezto** - Zsh framework configuration
- **topgrade** - Tool for updating all package managers at once
- **vs-code** - Visual Studio Code settings and keybindings
- **zsh** - Zsh shell configuration

## AI Agent Configuration

Two topics manage AI coding agent configuration, wired into place with per-item symlinks so every tweak is tracked in git:

- **`src/topics/agentrc.symlink/`** (symlinked to `~/.agentrc`) - agent-agnostic config shared by Claude Code, Codex, Gemini and OpenCode: global instructions (`AGENTS.md`), skills and standards. See its [README](src/topics/agentrc.symlink/README.md).
- **`src/topics/claude/`** - Claude Code specifics: `settings.json`, a gitignored `settings.local.json` overlay, `statusline.sh`, hooks and subagents (`agents/`).

### How it's wired

`src/topics/claude/install.sh` symlinks individual items into `~/.claude` (never the whole directory, which holds runtime state):

- `~/.claude/statusline.sh`, `agents/` → `src/topics/claude/`
- `~/.claude/settings.json` is a generated merge of `settings.json` and the gitignored `settings.local.json` (see `merge-settings.sh`), kept current by a `claude-settings-sync` LaunchAgent whose plist is rendered from `com.jppferguson.claude-settings-sync.plist.template` into `~/Library/LaunchAgents/`
- `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/.config/opencode/AGENTS.md` → `src/topics/agentrc.symlink/AGENTS.md`
- `~/.claude/skills/<name>` → `src/topics/agentrc.symlink/skills/<name>` (individual links; the skills directory itself stays real because other tools install skills there too)

### Commands

- **`dot claude status`** - Check symlink, merged settings and LaunchAgent health
- **`dot claude sync`** - Re-merge settings, re-render and reload the LaunchAgent, and repair symlinks (pre-existing real files are backed up to `~/.claude/backups/`)
- **`dot claude backup`** - Create a manual backup of the linked config

### Workflow

Edit files in the repo (or in `~/.claude` - symlinks write through), then commit from the dotfiles repo. Changes apply to new agent sessions immediately. Edit `settings.json` or `settings.local.json` in the repo, not the generated `~/.claude/settings.json`: the LaunchAgent re-merges within seconds.

## Components

There's a few special files in the hierarchy.

- **src/bin/**: Anything in `src/bin/` will get added to your `$PATH` and be made
  available everywhere.
- **src/functions/**: Shell functions that get loaded into your environment.
- **src/script/**: Installation and maintenance scripts (bootstrap, install, test, etc.).
- **src/topics/\*/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **src/topics/\*/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **src/topics/\*/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **src/topics/\*/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `src/script/bootstrap`.
  A nested path such as `.config/ghostty/config.symlink` keeps its structure
  under `$HOME`, and a `*.symlink` directory is linked as a whole.
- **src/topics/\*/aliases.sh**: Any file named `aliases.sh` is sourced by
  `loadAllAliases` in both zsh and bash. It is the only topic file bash reads.
- **src/topics/\*/install.sh**: One-off setup for the topic, run by
  `dot install <topic>` and offered by `src/script/install`.
- **src/topics/\*/update.sh**: Maintenance for the topic, run by
  `src/script/update`. `dot update` itself only runs topgrade. A topic does not
  need both scripts.

## Thanks

Largely based off @holman's awesome repo, but also with some
help/ideas/blatent pilfering from these fantastic people:

- [@holman](https://github.com/holman/dotfiles)
- [@mathiasbyens](https://github.com/mathiasbynens/dotfiles)
- [@paulirish](https://github.com/paulirish/dotfiles)
