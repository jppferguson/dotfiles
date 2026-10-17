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

# Runs one of the ~/.functions helpers in a clean bash with $BATS_TEST_TMPDIR/bin
# first on PATH, so tests can stub the external tools it calls
helper() {
  run env PATH="$BATS_TEST_TMPDIR/bin:$PATH" bash --noprofile --norc -c '. "$DOTFILES/src/topics/bash/functions.symlink"; "$@"' _ "$@"
}

stub() {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  printf '#!/bin/sh\n%s\n' "$2" > "$BATS_TEST_TMPDIR/bin/$1"
  chmod +x "$BATS_TEST_TMPDIR/bin/$1"
}

@test "digga: queries each record type separately instead of ANY" {
  stub dig 'echo "dig $*" >> "$BATS_TEST_TMPDIR/dig.log"'
  helper digga example.com
  [ "$status" -eq 0 ]
  for type in A AAAA CNAME MX NS TXT SOA; do
    grep -q "example.com $type " "$BATS_TEST_TMPDIR/dig.log"
  done
  run grep -ci ' any ' "$BATS_TEST_TMPDIR/dig.log"
  [ "$output" = 0 ]
}

@test "gitexport: exports the current branch when there is no master" {
  git init -q -b main "$BATS_TEST_TMPDIR/repo"
  echo tracked > "$BATS_TEST_TMPDIR/repo/file.txt"
  git -C "$BATS_TEST_TMPDIR/repo" add file.txt
  git -C "$BATS_TEST_TMPDIR/repo" -c user.name=test -c user.email=test@example.com commit -q -m init
  cd "$BATS_TEST_TMPDIR/repo"
  helper gitexport "$BATS_TEST_TMPDIR/out"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/out/file.txt")" = tracked ]
  [ ! -e "$BATS_TEST_TMPDIR/out/.git" ]
}

@test "cp_p: copies paths that contain spaces" {
  mkdir -p "$BATS_TEST_TMPDIR/my src"
  echo hello > "$BATS_TEST_TMPDIR/my src/note.txt"
  helper cp_p "$BATS_TEST_TMPDIR/my src/note.txt" "$BATS_TEST_TMPDIR/my dst.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/my dst.txt")" = hello ]
}

@test "unidecode: decodes \\x{...} escapes" {
  helper unidecode 'smile \x{263A} caf\x{E9}'
  [ "$status" -eq 0 ]
  [ "$output" = "smile ☺ café" ]
}

@test "unidecode: treats its input as text, never as Perl code" {
  # The old version spliced this into a Perl string, where @{[ ]} runs code
  helper unidecode "@{[ system(q(touch $BATS_TEST_TMPDIR/ran)) ]}"
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/ran" ]
  [ "$output" = "@{[ system(q(touch $BATS_TEST_TMPDIR/ran)) ]}" ]
}

@test "httpcompression: is no longer defined" {
  helper type httpcompression
  [ "$status" -ne 0 ]
}

@test "gifify: pipes ffmpeg into gifsicle and writes next to a source with spaces" {
  stub ffmpeg 'echo "ffmpeg $*" >> "$BATS_TEST_TMPDIR/tools.log"; echo frames'
  stub gifsicle 'echo "gifsicle $*" >> "$BATS_TEST_TMPDIR/tools.log"; cat'
  touch "$BATS_TEST_TMPDIR/my clip.mov"
  helper gifify "$BATS_TEST_TMPDIR/my clip.mov"
  [ "$status" -eq 0 ]
  grep -q "ffmpeg -i $BATS_TEST_TMPDIR/my clip.mov " "$BATS_TEST_TMPDIR/tools.log"
  [ "$(cat "$BATS_TEST_TMPDIR/my clip.mov.gif")" = frames ]
}

@test "gifify --good: stops with an install hint when ImageMagick is missing" {
  stub ffmpeg 'echo "ffmpeg ran" >> "$BATS_TEST_TMPDIR/tools.log"'
  run env PATH="$BATS_TEST_TMPDIR/bin:/usr/bin:/bin" /bin/bash --noprofile --norc -c '. "$DOTFILES/src/topics/bash/functions.symlink"; gifify clip.mov --good'
  [ "$status" -eq 1 ]
  [[ "$output" == *"brew install imagemagick"* ]]
  [ ! -e "$BATS_TEST_TMPDIR/tools.log" ]
}
