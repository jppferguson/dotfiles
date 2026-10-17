#!/usr/bin/env bats
#
# Covers src/topics/claude/update.sh status/backup against a fixture HOME and
# DOTFILES, with launchctl stubbed on PATH so the real LaunchAgent is never
# queried or touched.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export DOTFILES="$BATS_TEST_TMPDIR/dotfiles"
  TOPIC="$DOTFILES/src/topics/claude"
  AGENTRC="$DOTFILES/src/topics/agentrc.symlink"

  mkdir -p "$HOME/.claude" "$TOPIC/agents" "$AGENTRC/skills/some-skill" "$DOTFILES/src/functions"
  cp "$REPO/src/functions/general" "$DOTFILES/src/functions/general"
  cp "$REPO/src/topics/claude/update.sh" "$REPO/src/topics/claude/merge-settings.sh" "$TOPIC/"
  touch "$TOPIC/statusline.sh" "$AGENTRC/AGENTS.md"
  echo '{"model": "opus", "env": {"A": "public"}}' > "$TOPIC/settings.json"
  echo '{"env": {"A": "local", "B": "local"}}' > "$TOPIC/settings.local.json"

  ln -s "$TOPIC/statusline.sh" "$HOME/.claude/statusline.sh"
  ln -s "$TOPIC/agents" "$HOME/.claude/agents"
  ln -s "$AGENTRC/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  mkdir -p "$HOME/.claude/skills"
  ln -s "$AGENTRC/skills/some-skill" "$HOME/.claude/skills/some-skill"
  bash "$TOPIC/merge-settings.sh"

  # launchctl stub: `print` succeeds unless AGENT_LOADED=false
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/launchctl" <<'EOF'
#!/usr/bin/env bash
[ "$1" = print ] && [ "${AGENT_LOADED:-true}" = true ]
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/launchctl"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "status: exits 0 when the merge is current and the agent is loaded" {
  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 0 ]
  assert_contains "ok      $HOME/.claude/settings.json"
  assert_contains "ok      claude-settings-sync LaunchAgent"
}

@test "status: reports stale merge when settings.local.json changed since the last merge" {
  echo '{"env": {"A": "edited"}}' > "$TOPIC/settings.local.json"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "stale merge $HOME/.claude/settings.json"
  refute_contains "real file, not a symlink"
}

@test "status: treats a missing settings.local.json as a merge of settings.json alone" {
  rm "$TOPIC/settings.local.json"
  bash "$TOPIC/merge-settings.sh"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 0 ]
}

@test "status: reports the LaunchAgent as not loaded" {
  AGENT_LOADED=false run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "agent not loaded"
  assert_contains "ok      $HOME/.claude/settings.json"
}

@test "status: flags a settings.json symlink, since the live file should be a generated merge" {
  rm "$HOME/.claude/settings.json"
  ln -s "$TOPIC/settings.json" "$HOME/.claude/settings.json"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "drift   $HOME/.claude/settings.json (symlink, expected a generated merge)"
}

@test "status: reports a missing settings.json" {
  rm "$HOME/.claude/settings.json"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "missing $HOME/.claude/settings.json"
}

@test "backup: copies the live merged settings.json unchanged" {
  run bash "$TOPIC/update.sh" backup
  [ "$status" -eq 0 ]

  local backup
  backup=$(ls -d "$HOME"/.claude/backups/manual-*)
  cmp "$HOME/.claude/settings.json" "$backup/settings.json"
}

plain_output () {
  printf '%s' "$output" | sed $'s/\033\\[[0-9;]*m//g'
}

# Plain [ ] so a failed match trips errexit (bash 3.2 ignores a failed [[ ]])
assert_contains () {
  local plain
  plain=$(plain_output)
  [ "${plain#*"$1"}" != "$plain" ] || { echo "expected output to contain: $1"; echo "$plain"; return 1; }
}

refute_contains () {
  local plain
  plain=$(plain_output)
  [ "${plain#*"$1"}" = "$plain" ] || { echo "expected output not to contain: $1"; echo "$plain"; return 1; }
}
