---
name: add-topic
description: Add a new topic directory to Jamie's dotfiles repo (~/.dotfiles) for a tool's config, wired into the topic/symlink system so it installs cleanly and stays in sync across machines. Use when the user asks to "add a topic for X", "track X's config in dotfiles", or similar, while working in ~/.dotfiles.
---

# add-topic

Add a new `src/topics/<name>/` directory for a tool, following this repo's existing conventions so the config installs via `dot install <name>` (or bootstrap) and stays version-controlled.

## Step 1: Find what actually needs tracking

Locate the tool's real config location (commonly `~/.config/<tool>/`, `~/.<tool>rc`, or `~/.<tool>/`). Read it before assuming anything is safe to symlink wholesale.

Split what you find into two buckets:

- **Config** - settings files the user hand-edits or wants identical across machines.
- **Runtime/install state** - logs, sockets, PID files, caches, session state, downloaded plugin/extension checkouts, lockfiles the tool regenerates itself. Never symlink this. A tool's plugin directory that contains a full git clone with its own `.git/`, build scripts, and compiled binaries (installed state, not authored config) is runtime state even if it also holds a JSON manifest - the manifest usually has machine-specific absolute paths baked in anyway.

When unsure whether something is config or generated state, treat it as generated state and leave it alone. It's easy to add later; hard to unwind after a broken symlink ships to another machine.

## Step 2: Choose the linking mechanism

Two mechanisms exist in this repo. Pick based on what Step 1 found.

**Plain `.symlink` convention** - `src/script/bootstrap`'s `install_dotfiles()` auto-discovers any file ending `.symlink` under `src/topics/` and links it into `$HOME`, stripping the extension. Nesting rule: a bare `name.symlink` directly under the topic dir becomes `~/.name`; a path containing a `/` (e.g. `.config/tool/file.symlink`) keeps that relative structure under `$HOME`.

Only use this when:
- The destination directory is *entirely* config (nothing to exclude from Step 1), so symlinking the whole thing (or a whole file) is safe.
- The path depth fits. Bootstrap runs `find "$DOTFILES_TOPIC_ROOT" -maxdepth 3 -name '*.symlink'` - that only reaches `topics/<name>/file.symlink` or `topics/<name>/subdir/file.symlink`. A path one level deeper, like `topics/<name>/.config/<name>/file.symlink`, is silently skipped and never linked. Verify with `find src/topics -maxdepth 3 -name '*.symlink'` and confirm your new file actually appears before relying on this path. (The `ghostty` topic currently ships a `.symlink` one level too deep and is not actually wired up by bootstrap - don't copy that pattern without checking depth first.)

**Per-item `install.sh`** - see `src/topics/claude/install.sh` and `src/topics/herdr/install.sh` for the template. Use this when:
- The config directory mixes real config with runtime/install state (most `~/.config/<tool>/` directories with logs/sockets/session files).
- The real path is nested deeper than the `.symlink` convention reaches.

The template's `link_item()` helper: skips if already correctly linked, backs up a pre-existing real file/dir to a timestamped `backups/` folder before replacing it, then `ln -sfn`. Copy that helper rather than re-deriving it.

`dot install <name>` already dispatches generically to `src/topics/<name>/install.sh` (see `sub_install` in `src/bin/dot`) - no changes to `src/bin/dot` are needed unless the topic needs extra subcommands (status/diff/sync/backup, as `claude` has via `sub_claude`). Don't add those unless asked; a plain `install.sh` is enough for a single config file.

## Step 3: Build the topic

1. `mkdir -p src/topics/<name>`
2. Copy the current config file(s) into the topic directory as the source of truth.
3. Write `install.sh` (or `.symlink`-suffixed files) per the mechanism chosen in Step 2.
4. Run it (`. src/topics/<name>/install.sh` or `dot symlink`) to actually convert the live file into a symlink now - adding files to the repo without linking them doesn't satisfy "keep this in sync."
5. Verify: `readlink` the destination and confirm it points into the repo.

## Step 4: Wire it into the README

Add a one-line bullet to the "Key Topics Included" list in `README.md`, alphabetically placed, matching the existing style (`- **name** - short description`). Only add a dedicated section (like "AI Agent Configuration") if the topic has real nuance to explain beyond one line.

## Rules

- Never commit unless the user explicitly asks - this applies here same as anywhere else in the repo.
- Don't invent subcommands, status/diff tooling, or abstractions the user didn't ask for. `claude`'s install.sh grew status/diff/sync/backup because its topic is unusually complex (multi-agent wiring); a single-file config topic doesn't need that.
- If Step 1 turns up something ambiguous (e.g. a plugin manifest that's part-config, part-generated-state), default to the narrower scope (config file only) and say so, rather than guessing wide.
