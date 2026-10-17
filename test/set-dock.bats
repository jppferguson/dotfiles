#!/usr/bin/env bats
#
# Covers src/topics/macos/set-dock.sh with dockutil and killall stubbed on
# PATH so the real Dock is never touched.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export DOTFILES="$REPO"
  STUBS="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$STUBS"
  printf '#!/bin/sh\necho "$@" >> "$BATS_TEST_TMPDIR/dockutil.log"\n' > "$STUBS/dockutil"
  printf '#!/bin/sh\n' > "$STUBS/killall"
  chmod +x "$STUBS/dockutil" "$STUBS/killall"
}

@test "set-dock.sh: exits 1 with an install hint when dockutil is missing" {
  run env PATH="/usr/bin:/bin" bash "$REPO/src/topics/macos/set-dock.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"brew install dockutil"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "set-dock.sh: only adds apps that exist in /Applications" {
  run env PATH="$STUBS:/usr/bin:/bin" bash "$REPO/src/topics/macos/set-dock.sh"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/dockutil.log" ]
  while IFS= read -r line
  do
    case "$line" in
      "--no-restart --add "*) [ -d "${line#--no-restart --add }" ];;
    esac
  done < "$BATS_TEST_TMPDIR/dockutil.log"
}
