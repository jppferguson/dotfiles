#!/usr/bin/env bats
#
# Covers src/topics/system/env.zsh locale exports.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

@test "env.zsh: sets LANG to en_GB.UTF-8" {
  run env -u LANG -u LC_ALL -u LC_CTYPE zsh -f -c '. "$1"; print -r -- "$LANG"' _ "$REPO/src/topics/system/env.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "en_GB.UTF-8" ]
}

@test "env.zsh: does not set LC_ALL or LC_CTYPE" {
  run env -u LANG -u LC_ALL -u LC_CTYPE zsh -f -c '. "$1"; print -r -- "[${LC_ALL-unset}][${LC_CTYPE-unset}]"' _ "$REPO/src/topics/system/env.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "[unset][unset]" ]
}
