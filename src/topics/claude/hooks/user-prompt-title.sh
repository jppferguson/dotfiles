#!/bin/bash
# UserPromptSubmit hook: picks up a session title Claude handed off via
# session-start-title.sh's Bash file-write instruction, applies it, then
# consumes (deletes) the file so a stale title can't reapply itself.
set -f

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')

[ -z "$session_id" ] && exit 0

title_file="$HOME/.claude/session-titles/$session_id.title"
[ -f "$title_file" ] || exit 0

title=$(cat "$title_file")
rm -f "$title_file"

[ -z "$title" ] && exit 0

title_json=$(printf '%s' "$title" | jq -Rs .)
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","sessionTitle":%s}}' "$title_json"
