#!/usr/bin/env bats
#
# Covers the bash startup chain (bash_profile -> ~/.functions) against a
# fixture HOME, so the real dotfiles in $HOME are never read.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export DOTFILES="$REPO"
  mkdir -p "$HOME"
  ln -s "$REPO/src/topics/bash/functions.symlink" "$HOME/.functions"
}

@test "bash startup: extract is available without zsh autoloading" {
  run bash --noprofile --norc -c '. "$DOTFILES/src/topics/bash/bash_profile.symlink" >/dev/null 2>&1; type extract'
  [ "$status" -eq 0 ]
}
