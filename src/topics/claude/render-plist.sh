#!/usr/bin/env bash
#
# Prints the claude-settings-sync LaunchAgent plist to stdout, with the
# template's __HOME__ and __DOTFILES__ placeholders resolved for this machine.
# Used by install.sh to write the live plist and by update.sh to check that
# the live plist still matches what would be rendered now.
#
set -euo pipefail

DOTFILES_CLAUDE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$DOTFILES_CLAUDE/../../.." && pwd)"

sed -e "s|__HOME__|$HOME|g" -e "s|__DOTFILES__|$DOTFILES|g" \
    "$DOTFILES_CLAUDE/com.jppferguson.claude-settings-sync.plist.template"
