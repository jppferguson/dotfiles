---
name: add-topic
description: Add a new topic directory to Jamie's dotfiles repo (~/.dotfiles) for a tool's config or shell setup, wired into the topic/symlink system so it installs cleanly and stays in sync across machines. Checks viability first and declines when there is nothing safely trackable. Use when the user asks to "add a topic for X", "track X's config in dotfiles", "/add-topic", or similar, while working in ~/.dotfiles.
---

# add-topic

Add a new `src/topics/<name>/` directory for a tool, following this repo's existing conventions so the config installs via `dot install <name>` (or bootstrap) and stays version-controlled. Not every tool deserves a topic: the first job is deciding whether this one does.

## Topic anatomy

What each file in a topic does, and what picks it up. Only create the files the topic actually needs.

| File | Picked up by | Effect |
| --- | --- | --- |
| `path.zsh` | `zshrc.symlink`, first, in alphabetical topic order | PATH and env setup. Runs before everything else |
| `*.zsh` (other) | `zshrc.symlink`, after all `path.zsh` | Shell functions, env, init hooks |
| `completion.zsh` | `zshrc.symlink`, last, after compinit | Completions |
| `aliases.sh` | `loadAllAliases` in `src/functions/common` (zsh and bash) | Aliases |
| `*.symlink` | `install_dotfiles()` in `src/script/bootstrap` (`dot symlink`) | Linked into `$HOME`, extension stripped |
| `install.sh` | `src/script/install` (run manually on a fresh machine; offers every topic interactively, skippable via `DOTFILES_IGNORE` in `~/.localrc`) and `dot install <name>` | One-off setup: per-item symlinks, package installs |
| `update.sh` | `src/script/update` (run manually; finds every `update.sh`). `dot update` only runs topgrade | Re-runnable maintenance |

Notes:

- `path.zsh` files are zsh-only; bash never loads them. That is acceptable (zsh is the login shell); don't duplicate PATH lines into bash files unless asked.
- Because `path.zsh` runs alphabetically, `homebrew/path.zsh` prepends after `asdf/path.zsh`; `zshrc.symlink` re-asserts asdf shims afterwards. Prepend for tools that should win, append (`$PATH:...`) for tools that should lose to brew/asdf.
- Use `$HOME`, never a literal `/Users/<name>` path. Installers (Docker Desktop, Kimi, etc.) inject hardcoded PATH lines into `zprofile`/`zshrc`/`bash_profile`; the fix is a topic `path.zsh` plus removing the injected lines, as the `docker` and `kimi-code` topics do.
- A topic can be just a `path.zsh` (see `bun`, `docker`, `kimi-code`). That is a valid, complete topic.
- `install.sh` and `update.sh` are independent and both optional. Most topics ship neither (shell-only), some only `install.sh` (`herdr`, `hammerspoon`, `z`), and a topic with both keeps them paired (`vs-code`, `fonts`). Don't add an `update.sh` that `dot update` will never run: either register it in `topgrade.toml.symlink`'s `[commands]` block, as `vs-code` does, or leave it out.
- A `*.symlink` can be a directory (`hammerspoon/hammerspoon.symlink` becomes `~/.hammerspoon`), and a path with a `/` such as `.config/<tool>/file.symlink` keeps its structure under `$HOME`.
- `aliases.sh` is the only per-topic alias file bash reads (bash also sources the `bash` topic's own `aliases.symlink` and `functions.symlink`); `*.zsh` is zsh only. Put aliases bash also needs in `aliases.sh`.
- The authoritative table is the "Topic contract" section of `AGENT_CONTEXT.md`; keep the two in step.

## Step 0: Decide whether a topic is viable

Before creating anything, investigate the tool and decide. Decline (create nothing) and tell the user why when any of these hold for everything you found:

- **Settings live in a database or binary store** the app owns and rewrites (SQLite, LevelDB, IndexedDB, encrypted blobs). A symlink can't track it and a copy goes stale or corrupts it.
- **Settings already sync** through the app's own account or cloud profile, so the topic would add nothing.
- **Everything on disk is runtime or generated state**: caches, sockets, locks, logs, keys, session files, or scripts/hooks the app regenerates on update.
- **Config mixes in machine- or account-specific values** (account IDs, device keys, absolute paths, tokens) that can't be split out from the portable settings.
- **The need is already covered elsewhere**: the app install belongs in `src/topics/homebrew/Brewfile.symlink`; macOS app preferences stored in plists belong in `src/topics/macos/defaults/<app>.yaml`.

When declining, say what you found and where, why each piece fails the test, and the useful alternative if there is one (typically a Brewfile entry or a `macos/defaults` YAML). Don't offer to build export/import scripts against a private storage format unless the user asks; those break on app updates.

Proceed only when there is at least one thing that is portable, hand-editable (or worth keeping identical across machines), and either a plain file or a PATH/shell setup need.

## Step 1: Find what actually needs tracking

Locate the tool's real config location (commonly `~/.config/<tool>/`, `~/.<tool>rc`, `~/.<tool>/`, or `~/Library/Application Support/<tool>/`). Read it before assuming anything is safe to symlink wholesale.

Split what you find into two buckets:

- **Config** - settings files the user hand-edits or wants identical across machines.
- **Runtime/install state** - logs, sockets, PID files, caches, session state, downloaded plugin/extension checkouts, lockfiles the tool regenerates itself. Never symlink this. A tool's plugin directory that contains a full git clone with its own `.git/`, build scripts, and compiled binaries (installed state, not authored config) is runtime state even if it also holds a JSON manifest - the manifest usually has machine-specific absolute paths baked in anyway.

When unsure whether something is config or generated state, treat it as generated state and leave it alone. It's easy to add later; hard to unwind after a broken symlink ships to another machine.

Also check for secrets in anything you plan to track. Tokens and keys stay out of the repo; put them in `~/.localrc` or leave them where they are and add the path to `.gitignore` if it sits inside the repo.

## Step 2: Choose the linking mechanism

Skip this step for a shell-only topic (just `path.zsh`, `aliases.sh` or other `*.zsh`).

**Plain `.symlink` convention** - `install_dotfiles()` auto-discovers any file ending `.symlink` under `src/topics/` and links it into `$HOME`, stripping the extension. Nesting rule: a bare `name.symlink` directly under the topic dir becomes `~/.name`; a path containing a `/` (e.g. `.config/tool/file.symlink`) keeps that relative structure under `$HOME`.

Only use this when:

- The destination directory is *entirely* config (nothing to exclude from Step 1), so symlinking the whole thing (or a whole file) is safe.

**Per-item `install.sh`** - see `src/topics/claude/install.sh` and `src/topics/herdr/install.sh` for the template. Use this when:

- The config directory mixes real config with runtime/install state (most `~/.config/<tool>/` directories with logs/sockets/session files).

The template's `link_item()` helper: skips if already correctly linked, backs up a pre-existing real file/dir to a timestamped `backups/` folder before replacing it, then `ln -sfn`. Copy that helper rather than re-deriving it.

`dot install <name>` already dispatches generically to `src/topics/<name>/install.sh` (see `sub_install` in `src/bin/dot`) - no changes to `src/bin/dot` are needed unless the topic needs extra subcommands (status/diff/sync/backup, as `claude` has via `sub_claude`). Don't add those unless asked; a plain `install.sh` is enough for a single config file. Remember a new `install.sh` also runs on every fresh-machine install, so keep it idempotent.

## Step 3: Build the topic

1. `mkdir -p src/topics/<name>`
2. Copy the current config file(s) into the topic directory as the source of truth.
3. Write `install.sh`, `.symlink`-suffixed files, or the shell files per Step 2 and the anatomy table.
4. If an installer injected lines into `zprofile.symlink`, `zshrc.symlink` or `bash_profile.symlink` for this tool, remove them now that the topic covers it.
5. Run it (`. src/topics/<name>/install.sh` or `dot symlink`) to actually convert the live file into a symlink now - adding files to the repo without linking them doesn't satisfy "keep this in sync."
6. Verify:
   - Symlinks: `readlink` the destination and confirm it points into the repo.
   - Shell files: `zsh -n` each file, then `zsh -ic 'print -l $path'` (or the alias/function) in a fresh shell to confirm the effect.

## Step 4: Wire it into the README

Add a one-line bullet to the "Key Topics Included" list in `README.md`, alphabetically placed, matching the existing style (`- **name** - short description`). Only add a dedicated section (like "AI Agent Configuration") if the topic has real nuance to explain beyond one line.

## Rules

- Never commit unless the user explicitly asks - this applies here same as anywhere else in the repo.
- Declining is a valid outcome. A topic with nothing safely trackable is worse than no topic.
- Don't invent subcommands, status/diff tooling, or abstractions the user didn't ask for. `claude`'s install.sh grew status/diff/sync/backup because its topic is unusually complex (multi-agent wiring); a single-file config topic doesn't need that.
- If Step 1 turns up something ambiguous (e.g. a plugin manifest that's part-config, part-generated-state), default to the narrower scope (config file only) and say so, rather than guessing wide.
