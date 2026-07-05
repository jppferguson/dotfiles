# Cleanup backlog

Deferred items from the July 2026 repo review. The tidy-up branch handled the
security defaults, bootstrap bugs, dead topics/scripts, Brewfile rot and
shellcheck CI. What's left, roughly in priority order:

## Apply on existing machines (one-off, manual)

The defaults changes only affect future `dot macos` runs; already-applied
settings need reverting by hand:

- Re-enable download quarantine: `defaults delete com.apple.LaunchServices LSQuarantine`
- Laptops: turn off automatic login in System Settings > Users & Groups.
- Mac mini: keep auto-login by creating `src/topics/macos/defaults-local/login.yaml`
  (gitignored, applied automatically by `dot macos`):

  ```yaml
  ---
  description: Local overrides
  sudo: true
  data:
    com.apple.loginwindow:
      autoLoginUser: <your-username>
  ```

- If the LocalStack token in `~/.localrc` was ever live, rotate it and delete
  the commented-out line (it was never committed, this is just hygiene).

## Config conflicts to reconcile

- **zshenv collision**: `prezto/zshenv.symlink` and `zsh/zshenv.symlink` both
  map to `~/.zshenv`. Bootstrap will prompt about the clash every run. Merge
  them into one file and delete the other.
- **topgrade config divergence**: the live config is a plain file at
  `~/.config/topgrade.toml` (edited April 2025) and has drifted from the repo
  copy at `src/topics/topgrade/.config/topgrade.toml.symlink`. Diff them, fold
  the live changes into the repo, delete the plain file, then re-run
  `dot symlink` (the nested-path bug that caused this is now fixed). The
  legacy `~/.topgrade.toml` symlink can then be removed.
- **bun pinned twice**: `.tool-versions` (root) and `src/.tool-versions` both
  pin bun and will drift. Keep one.

## Security hardening (public repo)

- `src/topics/claude/settings.json` is public and combines auto mode,
  `skipAutoPermissionPrompt: true` and `Bash(curl:*)` - unrestricted egress if
  a prompt injection ever lands. Narrow or drop the curl allowance.
- Pin `anthropics/claude-code-action@beta` in both Claude workflows to a
  commit SHA or release tag.
- Strip the commented template cruft from `claude.yml` and
  `claude-code-review.yml`; consider whether auto-review on every PR is worth
  it for a solo repo.

## Tooling

- Add a scheduled (e.g. monthly) workflow on `macos-latest` running
  `brew bundle check --file=src/topics/homebrew/Brewfile.symlink` and
  `brew bundle list` validation to catch cask rot before it bites.
- Ratchet the shellcheck CI gate from `--severity=error` to `warning` and pay
  off the ~50 SC2086 quoting warnings (mostly in `src/functions/general`,
  `src/script/install` and the topic install scripts).
- Bats coverage is honest-but-thin: 4 of 26 tests run, the rest are
  `skip # TODO`. Either implement them (the `print_*`/`source_file*` ones are
  easy) or delete the skips. Nothing tests the bootstrap symlink mapping,
  which is where the real bugs were.

## Odds and ends

- `___NOTES.md`: the Brewfile TODOs in it are now done; the rest is mostly a
  raw dump of /Applications and VS Code extensions from 2024. Prune or delete.
- `src/topics/macos/to-migrate/`: decide whether to fold these defaults into
  `defaults/` or delete them.
- Brewfile: `evernote`, `opera`, `dropbox` + `google-drive` (both?) survived
  the purge but look questionable - review on the next `brew bundle` run.
- `bash` topic kept deliberately as a just-in-case fallback, but its aliases
  duplicate the zsh ones and will drift. Consider generating shared aliases
  from one source, or accept the drift.
- `node/npm-global` package list overlaps with topgrade's custom
  `npm update --location global` step - decide which owns global packages.
