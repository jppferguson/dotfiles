#!/usr/bin/env bats
#
# Covers src/topics/claude/claude-api.zsh, the claude-api wrapper.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  STUB_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$STUB_BIN"
  printf '#!/bin/sh\necho "args=[$*] key=[$ANTHROPIC_API_KEY]"\n' > "$STUB_BIN/claude"
  chmod +x "$STUB_BIN/claude"
}

@test "claude-api: passes the Keychain key and args to claude for that process only" {
  run env -u ANTHROPIC_API_KEY PATH="$STUB_BIN:$PATH" zsh -f -c '
    . "$1"
    security() { echo sk-ant-test; }
    claude-api -c --model "opus 5"
    print -r -- "after=[${ANTHROPIC_API_KEY-unset}]"' _ "$REPO/src/topics/claude/claude-api.zsh"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "args=[-c --model opus 5] key=[sk-ant-test]" ]
  [ "${lines[1]}" = "after=[unset]" ]
}

@test "claude-api: fails with setup instructions when the Keychain has no key" {
  run env -u ANTHROPIC_API_KEY PATH="$STUB_BIN:$PATH" zsh -f -c '
    . "$1"
    security() { return 44; }
    claude-api -p hi' _ "$REPO/src/topics/claude/claude-api.zsh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"security add-generic-password -s anthropic-api-key"* ]]
  [[ "$output" != *"args="* ]]
}
