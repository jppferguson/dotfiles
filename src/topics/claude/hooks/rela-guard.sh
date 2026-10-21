#!/bin/bash
# UserPromptSubmit and PreToolUse hook: refuses to work where a Rela .context/policy.yaml denies Claude Code
# (src/topics/rela). Checks the session cwd plus any path the tool names. Exit 2 blocks: a prompt is refused with
# the message shown to the user, a tool call with the message fed back to Claude.

guard_lib="${DOTFILES:-$HOME/.dotfiles}/src/topics/rela/lib/guard.sh"
[ -f "$guard_lib" ] || exit 0
. "$guard_lib"

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || cwd=$PWD

paths=()
while IFS= read -r target; do
    [ -n "$target" ] && paths+=("$target")
done < <(printf '%s' "$input" | jq -r '(.tool_input // {}) | .file_path, .path, .notebook_path | strings')

rela_guard claude-code "$cwd" "${paths[@]}" || exit 2
