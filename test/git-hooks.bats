#!/usr/bin/env bats
#
# Covers the global git hooks in src/topics/git/hooks, run in throwaway repos
# with GIT_CONFIG_GLOBAL pointed at a fixture so no real git config is touched.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
HOOKS="$REPO/src/topics/git/hooks"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export GIT_CONFIG_GLOBAL="$BATS_TEST_TMPDIR/gitconfig"
  export GIT_CONFIG_SYSTEM=/dev/null
  mkdir -p "$HOME" "$BATS_TEST_TMPDIR/project"
  printf '[user]\n  name = test\n  email = test@example.com\n[core]\n  hooksPath = %s\n' "$HOOKS" > "$GIT_CONFIG_GLOBAL"
  cd "$BATS_TEST_TMPDIR/project"
  git init -q
  # Assembled so this file does not itself trip the repo's gitleaks scan
  echo "token = ghp_$(printf 'aB3dE5fG7hJ9kL1mN3pQ5rS7tU9vW1xY3zA5')" > secret.txt
  echo "hello" > clean.txt
}

@test "git topic config enables the global hooks directory" {
  run grep -E '^\s*hooksPath = ~/.dotfiles/src/topics/git/hooks$' "$REPO/src/topics/git/gitconfig.symlink.example"
  [ "$status" -eq 0 ]
}

@test "pre-commit: blocks a staged secret in a repo without its own hooks" {
  git add secret.txt
  run git commit -q -m "add secret"
  [ "$status" -ne 0 ]
  [[ "$output" == *"leaks found"* ]]
}

@test "pre-commit: allows a clean commit" {
  git add clean.txt
  run git commit -q -m "add clean file"
  [ "$status" -eq 0 ]
}

@test "pre-commit: runs the repo's own hook after gitleaks passes" {
  printf '#!/bin/sh\necho ran > "%s/local-pre-commit"\n' "$BATS_TEST_TMPDIR" > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  git add clean.txt
  run git commit -q -m "add clean file"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/local-pre-commit")" = "ran" ]
}

@test "pre-commit: still blocks a secret when the repo has its own hook" {
  printf '#!/bin/sh\necho ran > "%s/local-pre-commit"\n' "$BATS_TEST_TMPDIR" > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  git add secret.txt
  run git commit -q -m "add secret"
  [ "$status" -ne 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/local-pre-commit" ]
}

@test "pre-commit: the repo's own failing hook still blocks the commit" {
  printf '#!/bin/sh\nexit 1\n' > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  git add clean.txt
  run git commit -q -m "add clean file"
  [ "$status" -ne 0 ]
}

@test "commit-msg: hands off to the repo's own hook with its arguments" {
  printf '#!/bin/sh\ncat "$1" > "%s/msg-seen"\nexit 1\n' "$BATS_TEST_TMPDIR" > .git/hooks/commit-msg
  chmod +x .git/hooks/commit-msg
  git add clean.txt
  run git commit -q -m "needs a ticket"
  [ "$status" -ne 0 ]
  grep -q "needs a ticket" "$BATS_TEST_TMPDIR/msg-seen"
}

@test "pre-push: hands off to the repo's own hook and passes stdin through" {
  git add clean.txt
  git commit -q -m "add clean file"
  git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
  git remote add origin "$BATS_TEST_TMPDIR/remote.git"
  printf '#!/bin/sh\necho "$1" > "%s/push-remote"\ncat > "%s/push-stdin"\nexit 1\n' "$BATS_TEST_TMPDIR" "$BATS_TEST_TMPDIR" > .git/hooks/pre-push
  chmod +x .git/hooks/pre-push
  run git push -q origin HEAD:refs/heads/main
  [ "$status" -ne 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/push-remote")" = "origin" ]
  grep -q "refs/heads/main" "$BATS_TEST_TMPDIR/push-stdin"
}

@test "every standard hook name in the directory resolves to the dispatcher" {
  for name in pre-commit commit-msg pre-push prepare-commit-msg post-commit post-merge post-checkout pre-rebase; do
    [ -x "$HOOKS/$name" ]
    [ "$(readlink "$HOOKS/$name")" = "run-hook" ]
  done
}

@test "husky-style repo keeps running its own hook (gitleaks is a documented gap there)" {
  mkdir -p .husky/_
  printf '#!/bin/sh\necho ran > "%s/husky-pre-commit"\n' "$BATS_TEST_TMPDIR" > .husky/_/pre-commit
  chmod +x .husky/_/pre-commit
  git config core.hooksPath .husky/_
  git add secret.txt
  run git commit -q -m "add secret"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/husky-pre-commit")" = "ran" ]
}

@test "linked worktree: hands off to the main repo's hook" {
  printf '#!/bin/sh\necho ran > "%s/local-pre-commit"\n' "$BATS_TEST_TMPDIR" > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  git add clean.txt
  git commit -q --no-verify -m "init"
  git worktree add -q "$BATS_TEST_TMPDIR/wt" -b feature
  cd "$BATS_TEST_TMPDIR/wt"
  echo more > more.txt
  git add more.txt
  run git commit -q -m "more"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/local-pre-commit")" = "ran" ]
}
