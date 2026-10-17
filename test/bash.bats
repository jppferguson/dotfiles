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

@test "extract: unpacks an archive whose name contains a space under bash" {
  mkdir -p "$BATS_TEST_TMPDIR/work/src"
  echo hello > "$BATS_TEST_TMPDIR/work/src/note.txt"
  (cd "$BATS_TEST_TMPDIR/work/src" && zip -q "../my archive.zip" note.txt)
  mkdir "$BATS_TEST_TMPDIR/work/out"
  cd "$BATS_TEST_TMPDIR/work/out"
  run bash --noprofile --norc -c '. "$DOTFILES/src/topics/bash/functions.symlink"; extract "../my archive.zip"'
  [ "$status" -eq 0 ]
  [ "$(cat note.txt)" = "hello" ]
}

@test "extract: unpacks an archive whose name contains a space under zsh" {
  command -v zsh >/dev/null || skip "zsh not installed"
  mkdir -p "$BATS_TEST_TMPDIR/work/src"
  echo hello > "$BATS_TEST_TMPDIR/work/src/note.txt"
  (cd "$BATS_TEST_TMPDIR/work/src" && zip -q "../my archive.zip" note.txt)
  mkdir "$BATS_TEST_TMPDIR/work/out"
  cd "$BATS_TEST_TMPDIR/work/out"
  run zsh -f -c 'fpath=("$DOTFILES/src/functions" $fpath); autoload -Uz extract; extract "../my archive.zip"'
  [ "$status" -eq 0 ]
  [ "$(cat note.txt)" = "hello" ]
}
