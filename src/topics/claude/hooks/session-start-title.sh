#!/bin/bash
# SessionStart hook: seeds a placeholder session title from the repo/folder
# name and tells Claude the "Project: Task" naming convention. Claude hands
# off the real task-aware title via a session-scoped file (never via reply
# text - reply text is always visible to the user, and prose that merely
# discusses this mechanism would otherwise be misread as a real title).
# user-prompt-title.sh picks the file up and applies it as sessionTitle.
set -f

input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
current_title=$(printf '%s' "$input" | jq -r '.session_title // empty')

titles_dir="$HOME/.claude/session-titles"
mkdir -p "$titles_dir"
title_file="$titles_dir/$session_id.title"

base_context="Session naming convention for this session: a short title in the form Project: Task - e.g. JD: Fix Auth Bugs or Dijam: SEO Tweaks. Keep the project reference short (abbreviate an obvious multi-word project name; use it as-is if already short), and the task part to 2-4 words in Title Case."
handoff_instruction="Once you have genuinely identified this session's task, hand off a title by running this exact Bash command, substituting your chosen title (do not put the title in your reply text): printf '%s' 'Project: Task' > $title_file -- e.g. printf '%s' 'JD: Fix Auth Bugs' > $title_file. Never run this merely when discussing or documenting this mechanism itself. Run it once per task, not every turn."

if [ -n "$current_title" ]; then
    context_json=$(printf '%s Current session title: %s. If that title does not already follow the convention above (for example, a generic auto-generated topic title), fix it on your next reply even though this is a resumed session, not a brand-new one. %s' \
        "$base_context" "$current_title" "$handoff_instruction" | jq -Rs .)
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}' "$context_json"
    exit 0
fi

context_json=$(printf '%s %s' "$base_context" "$handoff_instruction" | jq -Rs .)

repo=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)")
elif [ -n "$cwd" ]; then
    repo=$(basename "$cwd")
fi

if [ -n "$repo" ]; then
    display_repo=${repo#.}
    title_json=$(printf '%s' "$display_repo" | jq -Rs .)
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s,"sessionTitle":%s}}' "$context_json" "$title_json"
else
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}' "$context_json"
fi
