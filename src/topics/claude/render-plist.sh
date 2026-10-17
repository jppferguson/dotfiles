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

# Escape a value for use as a sed replacement (\ & and the | delimiter), after
# XML-escaping it since the result lands inside <string> elements. Done in sed
# rather than ${value//</&lt;}, because bash 5.2 expands & in that replacement
# to the matched text while macOS's bash 3.2 does not
escape_replacement() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' \
        -e 's/[\\&|]/\\&/g'
}

home_escaped="$(escape_replacement "$HOME")"
dotfiles_escaped="$(escape_replacement "$DOTFILES")"

sed -e "s|__HOME__|$home_escaped|g" -e "s|__DOTFILES__|$dotfiles_escaped|g" \
    "$DOTFILES_CLAUDE/com.jppferguson.claude-settings-sync.plist.template"
