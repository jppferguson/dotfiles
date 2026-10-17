#!/usr/bin/env bats
#
# Covers src/bin/code-or-vim: VS Code locally, vim over SSH or without `code`.
# Stub code and vim binaries on a restricted PATH record how they were called.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  STUBS="$BATS_TEST_TMPDIR/stubs"
  mkdir -p "$STUBS"
  for editor in code vim
  do
    printf '#!/bin/sh\necho "%s $*" > "$BATS_TEST_TMPDIR/called"\n' "$editor" > "$STUBS/$editor"
    chmod +x "$STUBS/$editor"
  done
  unset SSH_CONNECTION SSH_TTY GIT_EDITOR VISUAL EDITOR
}

@test "code-or-vim: runs code --wait locally" {
  PATH="$STUBS:$PATH" run "$REPO/src/bin/code-or-vim" COMMIT_EDITMSG
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/called")" = "code --wait COMMIT_EDITMSG" ]
}

@test "code-or-vim: falls back to vim when SSH_CONNECTION is set" {
  SSH_CONNECTION="1.2.3.4 1 5.6.7.8 22" PATH="$STUBS:$PATH" run "$REPO/src/bin/code-or-vim" COMMIT_EDITMSG
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/called")" = "vim COMMIT_EDITMSG" ]
}

@test "code-or-vim: falls back to vim when SSH_TTY is set" {
  SSH_TTY=/dev/pts/0 PATH="$STUBS:$PATH" run "$REPO/src/bin/code-or-vim" COMMIT_EDITMSG
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/called")" = "vim COMMIT_EDITMSG" ]
}

@test "code-or-vim: falls back to vim when code is missing" {
  rm "$STUBS/code"
  # Keep /usr/bin and /bin for env and bash but not a real code binary
  PATH="$STUBS:/usr/bin:/bin" run "$REPO/src/bin/code-or-vim" COMMIT_EDITMSG
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/called")" = "vim COMMIT_EDITMSG" ]
}

@test "gitconfig.symlink: core.editor runs the wrapper from a bare PATH" {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  ln -s "$REPO" "$HOME/.dotfiles"
  editor="$(GIT_CONFIG_GLOBAL="$REPO/src/topics/git/gitconfig.symlink" git var GIT_EDITOR)"
  # git runs the editor through sh, which expands the leading ~
  SSH_CONNECTION="1.2.3.4 1 5.6.7.8 22" PATH="$STUBS:/usr/bin:/bin" run sh -c "$editor COMMIT_EDITMSG"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/called")" = "vim COMMIT_EDITMSG" ]
}

@test "gitconfig.symlink: the local include is the last section" {
  [ "$(grep -n '^\[' "$REPO/src/topics/git/gitconfig.symlink" | tail -1 | cut -d: -f2)" = "[include]" ]
}
