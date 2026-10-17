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
  cp "$REPO/src/topics/claude/install.sh" "$REPO/src/topics/claude/update.sh" "$REPO/src/topics/claude/merge-settings.sh" "$REPO/src/topics/claude/render-plist.sh" "$REPO/src/topics/claude/com.jppferguson.claude-settings-sync.plist.template" "$TOPIC/"
  touch "$TOPIC/statusline.sh" "$AGENTRC/AGENTS.md"
  echo '{"model": "opus", "env": {"A": "public"}}' > "$TOPIC/settings.json"
  echo '{"env": {"A": "local", "B": "local"}}' > "$TOPIC/settings.local.json"

  ln -s "$TOPIC/statusline.sh" "$HOME/.claude/statusline.sh"
  ln -s "$TOPIC/agents" "$HOME/.claude/agents"
  ln -s "$AGENTRC/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  mkdir -p "$HOME/.claude/skills"
  ln -s "$AGENTRC/skills/some-skill" "$HOME/.claude/skills/some-skill"
  bash "$TOPIC/merge-settings.sh"

  PLIST="$HOME/Library/LaunchAgents/com.jppferguson.claude-settings-sync.plist"
  mkdir -p "$HOME/Library/LaunchAgents"
  bash "$TOPIC/render-plist.sh" > "$PLIST"

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

@test "render-plist: resolves the placeholders to this HOME and DOTFILES" {
  run bash "$TOPIC/render-plist.sh"
  [ "$status" -eq 0 ]
  refute_contains "__HOME__"
  refute_contains "__DOTFILES__"
  assert_contains "<string>$DOTFILES/src/topics/claude/merge-settings.sh</string>"
  assert_contains "<string>$HOME/Library/Logs/claude-settings-sync.log</string>"
}

@test "render-plist: keeps sed and XML metacharacters in HOME and DOTFILES literal" {
  local odd_home="$BATS_TEST_TMPDIR/a&b|c\\d<e>"
  local odd_dotfiles="$BATS_TEST_TMPDIR/x&y|z"
  mkdir -p "$odd_dotfiles/src/topics"
  cp -R "$TOPIC" "$odd_dotfiles/src/topics/claude"

  HOME="$odd_home" run bash "$odd_dotfiles/src/topics/claude/render-plist.sh"
  [ "$status" -eq 0 ]
  refute_contains "__HOME__"
  refute_contains "__DOTFILES__"
  assert_contains "<string>$BATS_TEST_TMPDIR/x&amp;y|z/src/topics/claude/merge-settings.sh</string>"
  assert_contains "<string>$BATS_TEST_TMPDIR/a&amp;b|c\\d&lt;e&gt;/Library/Logs/claude-settings-sync.log</string>"
}

@test "install: leaves the live plist untouched when rendering fails" {
  echo "<!-- live -->" > "$PLIST"
  rm "$TOPIC/com.jppferguson.claude-settings-sync.plist.template"

  run bash "$TOPIC/install.sh"
  [ "$status" -ne 0 ]
  assert_contains "Failed to render $PLIST"
  refute_contains "Claude configuration installed"
  [ "$(cat "$PLIST")" = "<!-- live -->" ]
  [ ! -e "$PLIST.tmp" ]
}

@test "install: backs up a live settings.json that differs from the merge" {
  jq '.model = "sonnet"' "$HOME/.claude/settings.json" > "$BATS_TEST_TMPDIR/live.json"
  cp "$BATS_TEST_TMPDIR/live.json" "$HOME/.claude/settings.json"

  run bash "$TOPIC/install.sh"
  [ "$status" -eq 0 ]

  local backup
  backup=$(ls -d "$HOME"/.claude/backups/*/)
  cmp "$BATS_TEST_TMPDIR/live.json" "$backup/settings.json"
  assert_contains "${backup}settings.json"
  assert_contains "changes not in settings.json or settings.local.json"
  [ "$(jq -r .model "$HOME/.claude/settings.json")" = "opus" ]
}

@test "install: skips the settings.json backup when the live file matches the merge" {
  jq -S . "$HOME/.claude/settings.json" > "$BATS_TEST_TMPDIR/sorted.json"
  cp "$BATS_TEST_TMPDIR/sorted.json" "$HOME/.claude/settings.json"

  run bash "$TOPIC/install.sh"
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.claude/backups" ] || [ -z "$(find "$HOME/.claude/backups" -name settings.json)" ]
  refute_contains "backed up to"
}

@test "install: neither backs up nor fails when the live settings.json is missing" {
  rm "$HOME/.claude/settings.json"

  run bash "$TOPIC/install.sh"
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/settings.json" ]
  [ ! -e "$HOME/.claude/backups" ] || [ -z "$(find "$HOME/.claude/backups" -name settings.json)" ]
}

@test "install: neither backs up nor fails when the live settings.json is a symlink" {
  mv "$HOME/.claude/settings.json" "$BATS_TEST_TMPDIR/elsewhere.json"
  ln -s "$BATS_TEST_TMPDIR/elsewhere.json" "$HOME/.claude/settings.json"

  run bash "$TOPIC/install.sh"
  [ "$status" -eq 0 ]
  [ ! -L "$HOME/.claude/settings.json" ]
  [ ! -e "$HOME/.claude/backups" ] || [ -z "$(find "$HOME/.claude/backups" -name settings.json)" ]
}

@test "status: reports the rendered LaunchAgent plist as ok" {
  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 0 ]
  assert_contains "ok      $PLIST"
}

@test "status: reports a missing LaunchAgent plist" {
  rm "$PLIST"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "missing $PLIST"
}

@test "status: flags a LaunchAgent plist that no longer matches the template" {
  echo "<!-- edited -->" >> "$PLIST"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "drift   $PLIST (differs from the rendered template)"
}

@test "status: flags a LaunchAgent plist that is still a symlink" {
  rm "$PLIST"
  ln -s "$TOPIC/com.jppferguson.claude-settings-sync.plist.template" "$PLIST"

  run bash "$TOPIC/update.sh" status
  [ "$status" -eq 1 ]
  assert_contains "drift   $PLIST (symlink, expected a rendered file)"
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
