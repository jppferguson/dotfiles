#!/usr/bin/env bash
#
# Check/repair the symlinks that wire ~/.claude to this repo.
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

# name|expected-target pairs
LINKS=(
    "$CLAUDE_DIR/settings.json|$DOTFILES_CLAUDE/settings.json"
    "$CLAUDE_DIR/statusline.sh|$DOTFILES_CLAUDE/statusline.sh"
    "$CLAUDE_DIR/agents|$DOTFILES_CLAUDE/agents"
    "$CLAUDE_DIR/CLAUDE.md|$AGENTRC/AGENTS.md"
)

# Shared skills are linked individually (~/.claude/skills itself stays real)
for skill in "$AGENTRC"/skills/*/; do
    name=$(basename "$skill")
    LINKS+=("$CLAUDE_DIR/skills/$name|${skill%/}")
done

show_status() {
    local broken=0
    info "Claude configuration symlink status:\n"
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
        echo -e "\n${YELLOW}Run 'dot claude sync' to repair symlinks (existing files are backed up)${NC}"
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
