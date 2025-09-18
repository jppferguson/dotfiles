# Repository Guidelines

## Project Structure & Module Organization

Core automation lives under `src/`. Use `src/bin/` for executables placed on `$PATH`, `src/functions/` for shared shell helpers, and `src/script/` for lifecycle scripts such as `bootstrap` and `test`. Shell “topics” belong in `src/topics/<topic>/`; files ending in `.zsh` auto-load, and `.symlink` files map into `$HOME` when `dot symlink` runs. Tests sit in `test/*.bats`, while vendored tooling (e.g., Bats libs) resides in `vendor/`. Keep personal notes in `___NOTES.md` and leave shared docs under the repo root.

## Build, Test, and Development Commands

Run `./src/script/bootstrap` after cloning to refresh symlinks and install prerequisites. Use `dot help` for a quick command index and `dot symlink` whenever you add or rename `.symlink` files. Execute `dot test` (wrapper around Bats) or `./src/script/test` to run the full suite. Apply environment defaults with `dot macos` and keep packages current with `dot update` (alias `dot upgrade`).

## Coding Style & Naming Conventions

All scripts target Bash; start new files with `#!/usr/bin/env bash` and prefer two-space indentation, matching `src/bin/dot`. Name shell functions in `snake_case` and keep topic directories lowercase (e.g., `src/topics/git`). When adding helpers, source them through `src/functions/` and gate external dependencies behind existence checks. Annotate tricky logic with brief comments and add `# shellcheck` directives when sourcing relative paths.

## Testing Guidelines

Author behavioural tests in Bats under `test/`, mirroring the function under test (e.g., `functions.bats` for `src/functions/general`). Follow the `@test "function(): does thing"` pattern and remove `skip` guards once a scenario is implemented. Always run `dot test` before opening a PR, and extend coverage whenever you introduce new shell utilities or modify CLI behaviour.

## Commit & Pull Request Guidelines

Keep commits focused and message them in imperative mood (`Add upgrade alias`, `Refine tskr`). Reference related issues in the body if applicable. PRs should summarize the change, note any config migrations, and include verification steps (`dot test`, `dot symlink`, etc.). Capture screenshots or terminal excerpts when altering interactive commands, and highlight follow-up tasks such as re-running `dot claude sync` when Claude assets change.

## Security & Configuration Tips

Treat dotfiles as public: never commit secrets or machine-specific tokens. When modifying Claude assets under `src/topics/claude/`, finish by running `dot claude sync` so local edits reach `~/.claude/`. Review `zsh/zshrc.symlink` updates carefully—call out any path changes in your PR and verify they do not break shared tooling.
