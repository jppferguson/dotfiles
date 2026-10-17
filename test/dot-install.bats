#!/usr/bin/env bats
#
# Covers `dot install <topic>` against a fixture DOTFILES, so a failing topic
# script is reported as itself rather than as a missing script.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export DOTFILES="$BATS_TEST_TMPDIR/dotfiles"
  mkdir -p "$DOTFILES/src/topics/working" "$DOTFILES/src/topics/failing" "$DOTFILES/src/topics/missing"
  echo 'echo "working ran"' > "$DOTFILES/src/topics/working/install.sh"
  printf 'echo "failing ran"\nfalse\nexit 3\n' > "$DOTFILES/src/topics/failing/install.sh"
}

@test "dot install: runs a topic install script and exits 0" {
  run "$REPO/src/bin/dot" install working
  [ "$status" -eq 0 ]
  [[ "$output" == *"working ran"* ]]
}

@test "dot install: propagates a failing script's output and status without the not-found message" {
  run "$REPO/src/bin/dot" install failing
  [ "$status" -eq 3 ]
  [[ "$output" == *"failing ran"* ]]
  [[ "$output" != *"Unable to find script"* ]]
}

@test "dot install: reports a topic with no install.sh and exits non-zero" {
  run "$REPO/src/bin/dot" install missing
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unable to find script to install missing"* ]]
}
