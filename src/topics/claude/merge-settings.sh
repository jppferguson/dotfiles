#!/usr/bin/env bash
#
# Deep-merges settings.json (public, git-tracked) with settings.local.json
# (gitignored, per-machine overlay - PATH, worktree dirs, autoMode infra
# notes) into ~/.claude/settings.json. Local wins on any key collision.
#
# Called from two places: install.sh at install time, and the
# com.jppferguson.claude-settings-sync LaunchAgent (WatchPaths on both
# source files) so editing either one takes effect within seconds with no
# manual re-run - the closest equivalent to the old plain symlink now that
# the content is split across a public and a local-only file.
#
set -euo pipefail

DOTFILES_CLAUDE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
PUBLIC="$DOTFILES_CLAUDE/settings.json"
OVERLAY="$DOTFILES_CLAUDE/settings.local.json"
DST="$CLAUDE_DIR/settings.json"

if [ ! -e "$PUBLIC" ]; then
    echo "merge-settings: missing $PUBLIC" >&2
    exit 1
fi

mkdir -p "$CLAUDE_DIR"

# Write via a temp file + atomic rename so nothing ever reads a
# half-written settings.json mid-merge.
tmp="$(mktemp "$CLAUDE_DIR/.settings.json.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

if [ -f "$OVERLAY" ]; then
    jq -s '.[0] * .[1]' "$PUBLIC" "$OVERLAY" > "$tmp"
else
    cp "$PUBLIC" "$tmp"
fi

mv "$tmp" "$DST"
trap - EXIT
