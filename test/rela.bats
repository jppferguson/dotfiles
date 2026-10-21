#!/usr/bin/env bats
#
# Covers the rela topic's callers of personal-os's rela-guard: the codex wrapper, the Claude Code hook and the
# Hermes plugin. `node` is stubbed (RELA_GUARD_NODE), so the real guard is never needed: the stub records its
# arguments and exits with $STUB_GUARD_EXIT, printing a denial message on exit 1.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export DOTFILES="$REPO"
  WORK="$BATS_TEST_TMPDIR"
  export RELA_GUARD_JS="$WORK/guard/guard.js"
  export RELA_GUARD_NODE="$WORK/stub/node"
  export GUARD_ARGS="$WORK/guard-args"
  export STUB_GUARD_EXIT=0

  mkdir -p "$WORK/guard" "$WORK/stub" "$WORK/real" "$WORK/open/src" "$WORK/client/.context" "$WORK/client/src"
  touch "$RELA_GUARD_JS"
  echo "version: 1" > "$WORK/client/.context/policy.yaml"

  cat > "$RELA_GUARD_NODE" <<'EOF'
#!/usr/bin/env bash
shift
printf '%s\n' "$@" > "$GUARD_ARGS"
[ "$STUB_GUARD_EXIT" = 1 ] && echo "rela guard: stub denial" >&2
exit "$STUB_GUARD_EXIT"
EOF
  cat > "$WORK/real/codex" <<'EOF'
#!/usr/bin/env bash
echo "real codex $*"
EOF
  chmod +x "$RELA_GUARD_NODE" "$WORK/real/codex"
  export PATH="$REPO/src/topics/rela/bin:$WORK/real:$PATH"
}

hook_input() {
  printf '{"cwd": "%s", "hook_event_name": "PreToolUse", "tool_input": {"file_path": "%s"}}' "$1" "$2"
}

@test "codex wrapper: runs the real codex with its arguments when the guard allows" {
  cd "$WORK/client/src"
  run codex exec "hello world"
  [ "$status" -eq 0 ]
  [ "$output" = "real codex exec hello world" ]
  run cat "$GUARD_ARGS"
  [ "${lines[0]}" = "--tool" ] && [ "${lines[1]}" = "codex" ]
  [ "${lines[2]}" = "--cwd" ] && [ "${lines[3]}" = "$WORK/client/src" ]
}

@test "codex wrapper: exits 1 with the guard's message and never starts codex when denied" {
  cd "$WORK/client"
  STUB_GUARD_EXIT=1 run codex
  [ "$status" -eq 1 ]
  [ "$output" = "rela guard: stub denial" ]
}

@test "codex wrapper: with the guard not installed, runs as today where no policy applies" {
  rm "$RELA_GUARD_JS"
  cd "$WORK/open/src"
  run codex
  [ "$status" -eq 0 ]
  [ "$output" = "real codex " ]
}

@test "codex wrapper: with the guard not installed, fails closed under a policy" {
  rm "$RELA_GUARD_JS"
  cd "$WORK/client/src"
  run codex
  [ "$status" -eq 1 ]
  [[ "$output" == *"codex is denied: $WORK/client/.context/policy.yaml applies here"*"not installed"* ]]
}

@test "codex wrapper: a crashing guard fails closed only where a policy applies" {
  cd "$WORK/client"
  STUB_GUARD_EXIT=70 run codex
  [ "$status" -eq 1 ]
  [[ "$output" == *"(exit 70), so failing closed"* ]]

  cd "$WORK/open"
  STUB_GUARD_EXIT=70 run codex
  [ "$status" -eq 0 ]
}

@test "claude hook: exit 2 with the guard's message when denied, 0 when allowed" {
  STUB_GUARD_EXIT=1 run bash "$REPO/src/topics/claude/hooks/rela-guard.sh" <<< "$(hook_input "$WORK/client" "$WORK/client/a.ts")"
  [ "$status" -eq 2 ]
  [ "$output" = "rela guard: stub denial" ]

  run bash "$REPO/src/topics/claude/hooks/rela-guard.sh" <<< "$(hook_input "$WORK/open" "")"
  [ "$status" -eq 0 ]
}

@test "claude hook: passes the session cwd and the tool's path to the guard" {
  run bash "$REPO/src/topics/claude/hooks/rela-guard.sh" <<< "$(hook_input "$WORK/open" "$WORK/client/src/new.ts")"
  [ "$status" -eq 0 ]
  run cat "$GUARD_ARGS"
  [ "$output" = "$(printf '%s\n' --tool claude-code --cwd "$WORK/open" --path "$WORK/client/src/new.ts")" ]
}

@test "claude hook: a tool path into a policy checkout fails closed without the guard" {
  rm "$RELA_GUARD_JS"
  run bash "$REPO/src/topics/claude/hooks/rela-guard.sh" <<< "$(hook_input "$WORK/open" "$WORK/client/src/new.ts")"
  [ "$status" -eq 2 ]
  [[ "$output" == *"claude-code is denied"* ]]
}

hermes() {
  python3 - "$@" <<EOF
import importlib.util, json, os, sys
spec = importlib.util.spec_from_file_location("rela_guard", "$REPO/src/topics/rela/hermes/rela-guard/__init__.py")
plugin = importlib.util.module_from_spec(spec)
spec.loader.exec_module(plugin)
$(cat)
EOF
}

@test "hermes plugin: maps the configured provider or model to a vendor, else unknown" {
  command -v python3 >/dev/null || skip "python3 not installed"
  run hermes <<'EOF'
cases = [
  ({"model": {"provider": "openai-codex", "default": "gpt-6-luna"}}, "openai"),
  ({"model": {"provider": "anthropic"}}, "anthropic"),
  ({"model": {"provider": "openrouter", "default": "anthropic/claude-sonnet"}}, "anthropic"),
  ({"model": {"provider": "openrouter", "default": "hermes-4-405b"}}, "nous"),
  ({"model": {"provider": "custom", "default": "mystery-model"}}, "unknown"),
  ({}, "unknown"),
  (None, "unknown"),
]
for config, expected in cases:
    assert plugin.configured_vendor(config) == expected, (config, plugin.configured_vendor(config))
print("ok")
EOF
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}

@test "hermes plugin: blocks with the guard's message, passing hermes, the vendor and the paths" {
  command -v python3 >/dev/null || skip "python3 not installed"
  mkdir -p "$WORK/hermes-home"
  printf 'model:\n  provider: openai-codex\n' > "$WORK/hermes-home/config.yaml"
  python3 -c 'import yaml' 2>/dev/null || skip "PyYAML not installed"
  STUB_GUARD_EXIT=1 HERMES_HOME="$WORK/hermes-home" TERMINAL_CWD="$WORK/open" run hermes <<EOF
print(json.dumps(plugin.pre_tool_call(tool_name="read_file", args={"path": "$WORK/client/a.ts"})))
EOF
  [ "$status" -eq 0 ]
  [ "$output" = '{"action": "block", "message": "rela guard: stub denial"}' ]
  run cat "$GUARD_ARGS"
  [ "$output" = "$(printf '%s\n' --tool hermes --vendor openai --cwd "$WORK/open" --path "$WORK/client/a.ts")" ]
}

@test "hermes plugin: allows when the guard does, and fails closed without it only under a policy" {
  command -v python3 >/dev/null || skip "python3 not installed"
  TERMINAL_CWD="$WORK/client" run hermes <<'EOF'
print(plugin.pre_tool_call(tool_name="terminal", args={"command": "ls"}))
EOF
  [ "$output" = "None" ]

  rm "$RELA_GUARD_JS"
  TERMINAL_CWD="$WORK/client/src" run hermes <<'EOF'
print(plugin.pre_tool_call(tool_name="terminal", args={})["message"])
EOF
  [[ "$output" == *"hermes is denied: $WORK/client/.context/policy.yaml applies here"* ]]

  TERMINAL_CWD="$WORK/open" run hermes <<'EOF'
print(plugin.pre_tool_call(tool_name="terminal", args={}))
EOF
  [ "$output" = "None" ]
}
