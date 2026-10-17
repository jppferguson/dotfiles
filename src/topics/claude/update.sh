#!/usr/bin/env bash
#
# Check/repair the symlinks and merged settings that wire ~/.claude to this repo.
# Usage: dot claude {status|sync|backup}
#

. $DOTFILES/src/functions/general

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"
DOTFILES_CLAUDE="$DOTFILES/src/topics/claude"
AGENTRC="$DOTFILES/src/topics/agentrc.symlink"
SETTINGS="$CLAUDE_DIR/settings.json"
SYNC_AGENT="com.jppferguson.claude-settings-sync"
SYNC_PLIST="$HOME/Library/LaunchAgents/$SYNC_AGENT.plist"

# name|expected-target pairs. settings.json isn't here: install.sh generates
# it as a merge of settings.json + settings.local.json (see merge-settings.sh)
LINKS=(
    "$CLAUDE_DIR/statusline.sh|$DOTFILES_CLAUDE/statusline.sh"
    "$CLAUDE_DIR/agents|$DOTFILES_CLAUDE/agents"
    "$CLAUDE_DIR/CLAUDE.md|$AGENTRC/AGENTS.md"
)

# Shared skills are linked individually (~/.claude/skills itself stays real)
for skill in "$AGENTRC"/skills/*/; do
    name=$(basename "$skill")
    LINKS+=("$CLAUDE_DIR/skills/$name|${skill%/}")
done

# What merge-settings.sh would write right now, key-sorted for comparison
expected_settings() {
    if [ -f "$DOTFILES_CLAUDE/settings.local.json" ]; then
        jq -s '.[0] * .[1]' "$DOTFILES_CLAUDE/settings.json" "$DOTFILES_CLAUDE/settings.local.json" | jq -S .
    else
        jq -S . "$DOTFILES_CLAUDE/settings.json"
    fi
}

show_settings_status() {
    if [ -L "$SETTINGS" ]; then
        echo -e "  ${RED}drift${NC}   $SETTINGS (symlink, expected a generated merge)"
        return 1
    elif [ ! -e "$SETTINGS" ]; then
        echo -e "  ${RED}missing${NC} $SETTINGS"
        return 1
    elif [ "$(jq -S . "$SETTINGS" 2>/dev/null)" != "$(expected_settings)" ]; then
        echo -e "  ${RED}stale merge${NC} $SETTINGS (differs from settings.json + settings.local.json)"
        return 1
    fi
    echo -e "  ${GREEN}ok${NC}      $SETTINGS"
}

# The live plist is rendered from a template (machine-specific paths), so it
# is compared against a fresh render rather than checked as a symlink
show_sync_plist_status() {
    if [ ! -e "$SYNC_PLIST" ] && [ ! -L "$SYNC_PLIST" ]; then
        echo -e "  ${RED}missing${NC} $SYNC_PLIST"
        return 1
    elif [ -L "$SYNC_PLIST" ]; then
        echo -e "  ${RED}drift${NC}   $SYNC_PLIST (symlink, expected a rendered file)"
        return 1
    elif [ "$(cat "$SYNC_PLIST")" != "$(bash "$DOTFILES_CLAUDE/render-plist.sh")" ]; then
        echo -e "  ${RED}drift${NC}   $SYNC_PLIST (differs from the rendered template)"
        return 1
    fi
    echo -e "  ${GREEN}ok${NC}      $SYNC_PLIST"
}

show_sync_agent_status() {
    if launchctl print "gui/$(id -u)/$SYNC_AGENT" >/dev/null 2>&1; then
        echo -e "  ${GREEN}ok${NC}      claude-settings-sync LaunchAgent"
    else
        echo -e "  ${RED}agent not loaded${NC} $SYNC_AGENT (settings.json won't re-merge on edits)"
        return 1
    fi
}

show_status() {
    local broken=0
    info "Claude configuration status:\n"
    show_settings_status || broken=1
    show_sync_plist_status || broken=1
    show_sync_agent_status || broken=1
    for pair in "${LINKS[@]}"; do
        local dst="${pair%%|*}"
        local src="${pair##*|}"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            echo -e "  ${GREEN}ok${NC}      $dst"
        elif [ -e "$dst" ]; then
            echo -e "  ${RED}drift${NC}   $dst (real file, not a symlink)"
            broken=1
        else
            echo -e "  ${RED}missing${NC} $dst"
            broken=1
        fi
    done
    if [ "$broken" = 1 ]; then
        echo -e "\n${YELLOW}Run 'dot claude sync' to re-merge settings, reload the agent and repair symlinks (existing files are backed up)${NC}"
        return 1
    fi
    echo -e "\n${GREEN}All Claude configuration is linked to the dotfiles repo${NC}"
}

case "${1:-status}" in
    "status")
        show_status
        ;;
    "sync")
        "$DOTFILES_CLAUDE/install.sh"
        ;;
    "backup")
        backup_dir="$CLAUDE_DIR/backups/manual-$(date +%Y-%m-%d-%H%M%S)"
        mkdir -p "$backup_dir"
        [ -e "$SETTINGS" ] && cp -RL "$SETTINGS" "$backup_dir/"
        for pair in "${LINKS[@]}"; do
            dst="${pair%%|*}"
            [ -e "$dst" ] && cp -RL "$dst" "$backup_dir/"
        done
        print_success "Manual backup created: $backup_dir"
        ;;
    *)
        echo "Usage: $0 {status|sync|backup}"
        exit 1
        ;;
esac
