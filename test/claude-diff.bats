#!/usr/bin/env bats
#
# Covers `dot claude diff` (src/topics/claude/update.sh diff) against a fixture
# HOME and DOTFILES. Kept apart from claude.bats so it does not depend on that
# file's launchctl and plist fixture.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export DOTFILES="$BATS_TEST_TMPDIR/dotfiles"
  TOPIC="$DOTFILES/src/topics/claude"
  AGENTRC="$DOTFILES/src/topics/agentrc.symlink"

  mkdir -p "$HOME/.claude/skills" "$HOME/.claude/hooks" "$TOPIC/agents" "$TOPIC/hooks" \
    "$AGENTRC/skills/some-skill" "$DOTFILES/src/functions"
  cp "$REPO/src/functions/general" "$DOTFILES/src/functions/general"
  cp "$REPO/src/topics/claude/update.sh" "$REPO/src/topics/claude/merge-settings.sh" "$TOPIC/"
  touch "$TOPIC/statusline.sh" "$AGENTRC/AGENTS.md" "$TOPIC/hooks/session-start-title.sh"
  echo '{"model": "opus", "env": {"A": "public"}}' > "$TOPIC/settings.json"
  echo '{"env": {"A": "local", "B": "local"}}' > "$TOPIC/settings.local.json"

  ln -s "$TOPIC/statusline.sh" "$HOME/.claude/statusline.sh"
  ln -s "$TOPIC/agents" "$HOME/.claude/agents"
  ln -s "$AGENTRC/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  ln -s "$TOPIC/hooks/session-start-title.sh" "$HOME/.claude/hooks/session-start-title.sh"
  ln -s "$AGENTRC/skills/some-skill" "$HOME/.claude/skills/some-skill"
  bash "$TOPIC/merge-settings.sh"
}

@test "diff: prints nothing and exits 0 when settings and links all match" {
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "diff: shows the changed keys of a drifted settings.json and still exits 0" {
  jq '.model = "sonnet" | .env.C = "hand-edited"' "$HOME/.claude/settings.json" > "$BATS_TEST_TMPDIR/edited.json"
  mv "$BATS_TEST_TMPDIR/edited.json" "$HOME/.claude/settings.json"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [[ "$output" == *'-  "model": "opus"'* ]]
  [[ "$output" == *'+  "model": "sonnet"'* ]]
  [[ "$output" == *'+    "C": "hand-edited"'* ]]
}

@test "diff: compares settings key-sorted, so key order alone is not a difference" {
  jq -S . "$HOME/.claude/settings.json" > "$BATS_TEST_TMPDIR/sorted.json"
  jq 'to_entries | reverse | from_entries' "$BATS_TEST_TMPDIR/sorted.json" > "$HOME/.claude/settings.json"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "diff: reports a link that points at the wrong target" {
  ln -sfn "$BATS_TEST_TMPDIR/elsewhere" "$HOME/.claude/statusline.sh"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"$HOME/.claude/statusline.sh points to $BATS_TEST_TMPDIR/elsewhere, expected $TOPIC/statusline.sh"* ]]
  [[ "$output" != *"agents"* ]]
}

@test "diff: reports a link replaced by a real file and a missing link" {
  rm "$HOME/.claude/CLAUDE.md" "$HOME/.claude/agents"
  echo local > "$HOME/.claude/CLAUDE.md"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"$HOME/.claude/CLAUDE.md is a real file"* ]]
  [[ "$output" == *"$HOME/.claude/agents is missing"* ]]
}

@test "diff: reports a missing or symlinked settings.json" {
  rm "$HOME/.claude/settings.json"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"$HOME/.claude/settings.json is missing"* ]]

  ln -s "$TOPIC/settings.json" "$HOME/.claude/settings.json"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"is a symlink, expected a generated merge"* ]]
}

@test "diff: is read-only" {
  echo '{"model": "sonnet"}' > "$HOME/.claude/settings.json"
  ln -sfn "$BATS_TEST_TMPDIR/elsewhere" "$HOME/.claude/statusline.sh"
  before="$(cd "$HOME" && find .claude -exec stat -f '%N %m %z %Y' {} + | sort; cat .claude/settings.json)"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 0 ]
  after="$(cd "$HOME" && find .claude -exec stat -f '%N %m %z %Y' {} + | sort; cat .claude/settings.json)"
  [ "$before" = "$after" ]
}

@test "diff: exits 1 with a message when jq is missing" {
  # Newer macOS ships /usr/bin/jq, so build a PATH with only what the script needs
  mkdir -p "$BATS_TEST_TMPDIR/nojq"
  for tool in bash basename dirname tput; do
    ln -s "$(command -v $tool)" "$BATS_TEST_TMPDIR/nojq/$tool"
  done
  run env PATH="$BATS_TEST_TMPDIR/nojq" "$BATS_TEST_TMPDIR/nojq/bash" "$TOPIC/update.sh" diff
  [ "$status" -eq 1 ]
  [[ "$output" == *"jq is required"* ]]
}

@test "diff: exits 1 with a message when merge-settings.sh is missing" {
  rm "$TOPIC/merge-settings.sh"
  run bash "$TOPIC/update.sh" diff
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing $TOPIC/merge-settings.sh"* ]]
}

@test "diff: no longer falls through to the usage message" {
  run bash "$TOPIC/update.sh" diff
  [[ "$output" != *"Usage"* ]]
}
