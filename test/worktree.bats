#!/usr/bin/env bats
#
# Covers wt() in src/topics/git/worktree.zsh, run under zsh in a temp git repo
# with a stub EDITOR that takes an argument.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  # wt compares $PWD with git's physical toplevel, so resolve the macOS /var symlink
  mkdir -p "$HOME" "$BATS_TEST_TMPDIR/project"
  PROJECT="$(cd "$BATS_TEST_TMPDIR/project" && pwd -P)"
  cd "$PROJECT"
  git init -q
  git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m init

  cat > "$BATS_TEST_TMPDIR/editor" <<'STUB'
#!/bin/sh
echo "$*" > "$BATS_TEST_TMPDIR/editor.log"
STUB
  chmod +x "$BATS_TEST_TMPDIR/editor"
}

@test "wt: opens the worktree with an EDITOR that has arguments" {
  EDITOR="$BATS_TEST_TMPDIR/editor -n" run zsh -c "source '$REPO/src/topics/git/worktree.zsh'; wt feature"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/editor.log")" = "-n $PROJECT-worktrees/feature" ]
}

@test "wt: opens the worktree with an EDITOR path that contains spaces" {
  mkdir -p "$BATS_TEST_TMPDIR/spaced dir"
  cp "$BATS_TEST_TMPDIR/editor" "$BATS_TEST_TMPDIR/spaced dir/editor"
  EDITOR="$BATS_TEST_TMPDIR/spaced dir/editor" run zsh -c "source '$REPO/src/topics/git/worktree.zsh'; wt feature"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/editor.log")" = "$PROJECT-worktrees/feature" ]
}

@test "wt: opens the worktree with a quoted EDITOR path that has spaces and arguments" {
  mkdir -p "$BATS_TEST_TMPDIR/spaced dir"
  cp "$BATS_TEST_TMPDIR/editor" "$BATS_TEST_TMPDIR/spaced dir/editor"
  EDITOR="'$BATS_TEST_TMPDIR/spaced dir/editor' -n" run zsh -c "source '$REPO/src/topics/git/worktree.zsh'; wt feature"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/editor.log")" = "-n $PROJECT-worktrees/feature" ]
}

@test "wt: returns non-zero when the editor fails to open" {
  EDITOR="$BATS_TEST_TMPDIR/missing-editor -n" run zsh -c "source '$REPO/src/topics/git/worktree.zsh'; wt feature"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Failed to open worktree"* ]]
  [[ "$output" != *"Successfully created"* ]]
}
