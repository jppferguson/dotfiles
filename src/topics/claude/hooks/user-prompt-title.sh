#!/bin/bash
# UserPromptSubmit hook: picks up a session title Claude handed off via
# session-start-title.sh's Bash file-write instruction, applies it, then
# consumes (deletes) the file so a stale title can't reapply itself. The
# title is normalised to kebab-case, and unless it carries a doto task id
# (8 hex chars) it gets a short session-id suffix so near-identical titles
# across sessions stay distinguishable. An optional second line is the
# session kind (bug/feature/chore/research), kept in <session>.kind for
# statusline.sh to colour the session name by.
set -f

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')

[ -z "$session_id" ] && exit 0

titles_dir="$HOME/.claude/session-titles"
title_file="$titles_dir/$session_id.title"
[ -f "$title_file" ] || exit 0

title=$(head -n 1 "$title_file" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
kind=$(sed -n 2p "$title_file" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
rm -f "$title_file"

case "$kind" in
    bug|feature|chore|research) printf '%s' "$kind" > "$titles_dir/$session_id.kind" ;;
esac

[ -z "$title" ] && exit 0

suffix=${session_id:0:4}
if ! printf '%s' "$title" | grep -Eq '(^|-)[0-9a-f]{8}(-|$)' && [ "${title%-"$suffix"}" = "$title" ]; then
    title="$title-$suffix"
fi

title_json=$(printf '%s' "$title" | jq -Rs .)
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","sessionTitle":%s}}' "$title_json"
