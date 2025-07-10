# Jamie ❤ ~/

Dotfiles are all those files beginning with a "." in your user directory and make your system (particularly anything to do with the command line) work and look the way you want it.

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/.dotfiles`).

The installation step requires the [XCode Command Line Tools](https://developer.apple.com/downloads), although you _should_ be prompted to install these if you don't have them installed already.

### Backups

Fair warning: The bootstrap script _attempts_ to backup existing dotfiles in your HOME directory, but to be safe you should probably make your own copy...

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
- **`dot dock`** - Apply macOS Dock settings
- **`dot duti`** - Set default apps for file types (UTI)
- **`dot edit`** - Open dotfiles in your IDE and Git GUI
- **`dot help`** - Show all available commands
- **`dot install {pkg}`** - Install a specific package/topic
- **`dot macos`** - Apply macOS system defaults
- **`dot reload`** - Reload shell configuration
- **`dot symlink`** - Re-run bootstrap to create/update symlinks
- **`dot test`** - Run tests
- **`dot update`** - Update all packages via topgrade

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/jppferguson/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md}
src/script/bootstrap
```

## Additional Commands

### Git Helpers

The repository includes several custom git commands in `src/topics/git/`:

- **`git-all`** - Stage all unstaged files
- **`git-amend`** - Amend commits easily
- **`git-nuke`** - Remove branches locally and remotely
- **`git-switcheroo`** - Switch between branches quickly
- **`git-track`** - Track remote branches
- **`git-undo`** - Undo the last commit
- **`git-unpushed`** - Show unpushed commits
- **`git-wtf`** - Show the current git status in detail

### Other Utilities

Additional commands available in `src/bin/`:

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

### Key Topics Included

- **asdf** - Version manager for Node.js, Ruby, and other tools
- **bash** - Bash shell configuration
- **duti** - Default application settings for file types on macOS
- **git** - Git configuration and custom commands
- **hammerspoon** - macOS automation and window management
- **homebrew** - Package management via Brewfile
- **macos** - macOS system defaults (YAML-based configuration)
- **node** - Node.js configuration and global packages
- **prezto** - Zsh framework configuration
- **sublime** - Sublime Text settings
- **topgrade** - Tool for updating all package managers at once
- **vs-code** - Visual Studio Code settings and keybindings
- **zsh** - Zsh shell configuration

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

## Thanks

Largely based off @holman's awesome repo, but also with some
help/ideas/blatent pilfering from these fantastic people:

- [@holman](https://github.com/holman/dotfiles)
- [@mathiasbyens](https://github.com/mathiasbynens/dotfiles)
- [@paulirish](https://github.com/paulirish/dotfiles)
