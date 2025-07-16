#!/usr/bin/env bash
#
# Update/sync Claude configuration with diff checking and backup support
#

# Include the general functions
. $DOTFILES/src/functions/general

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CLAUDE_DIR="$HOME/.claude"
DOTFILES_CLAUDE="$DOTFILES/src/topics/claude"

# Function to check if two files/directories are different
files_differ() {
    local src="$1"
    local dst="$2"
    
    if [ ! -e "$src" ] && [ ! -e "$dst" ]; then
        return 1  # Both don't exist, no difference
    elif [ ! -e "$src" ] || [ ! -e "$dst" ]; then
        return 0  # One exists, one doesn't, different
    fi
    
    if [ -d "$src" ] && [ -d "$dst" ]; then
        # Compare directories
        diff -r "$src" "$dst" >/dev/null 2>&1
        return $?
    elif [ -f "$src" ] && [ -f "$dst" ]; then
        # Compare files
        diff "$src" "$dst" >/dev/null 2>&1
        return $?
    else
        return 0  # Different types (file vs dir), different
    fi
}

# Function to show diff between dotfiles and ~/.claude
show_diff() {
    local name="$1"
    local src="$2"
    local dst="$3"
    
    if files_differ "$src" "$dst"; then
        echo -e "\n${YELLOW}=== $name ===${NC}"
        if [ -d "$src" ] && [ -d "$dst" ]; then
            diff -r "$src" "$dst" || true
        elif [ -f "$src" ] && [ -f "$dst" ]; then
            diff "$src" "$dst" || true
        elif [ ! -e "$dst" ]; then
            echo "File/directory does not exist in ~/.claude"
        elif [ ! -e "$src" ]; then
            echo "File/directory does not exist in dotfiles"
        fi
    fi
}

# Function to show status of all claude files
show_status() {
    local has_changes=false
    
    info "Claude configuration status:\n"
    
    # Check commands
    if files_differ "$DOTFILES_CLAUDE/commands" "$CLAUDE_DIR/commands"; then
        echo -e "  ${RED}✗${NC} commands (different)"
        has_changes=true
    else
        echo -e "  ${GREEN}✓${NC} commands (in sync)"
    fi
    
    # Check hooks
    if files_differ "$DOTFILES_CLAUDE/hooks" "$CLAUDE_DIR/hooks"; then
        echo -e "  ${RED}✗${NC} hooks (different)"
        has_changes=true
    else
        echo -e "  ${GREEN}✓${NC} hooks (in sync)"
    fi
    
    # Check settings.json
    if files_differ "$DOTFILES_CLAUDE/settings.json" "$CLAUDE_DIR/settings.json"; then
        echo -e "  ${RED}✗${NC} settings.json (different)"
        has_changes=true
    else
        echo -e "  ${GREEN}✓${NC} settings.json (in sync)"
    fi
    
    if [ "$has_changes" = true ]; then
        echo -e "\n${YELLOW}Run 'dot claude diff' to see differences${NC}"
        echo -e "${YELLOW}Run 'dot claude sync' to update ~/.claude from dotfiles${NC}"
        return 1
    else
        echo -e "\n${GREEN}All Claude configuration is in sync${NC}"
        return 0
    fi
}

# Function to create manual backup
create_backup() {
    local backup_dir="$CLAUDE_DIR/backups/manual-$(date +%Y-%m-%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$backup_dir/"
    [ -d "$CLAUDE_DIR/hooks" ] && cp -r "$CLAUDE_DIR/hooks" "$backup_dir/"
    [ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$backup_dir/"
    
    print_success "Manual backup created: $backup_dir"
}

# Main script logic
case "${1:-status}" in
    "status")
        show_status
        ;;
    "diff")
        info "Showing differences between dotfiles and ~/.claude:\n"
        show_diff "commands" "$DOTFILES_CLAUDE/commands" "$CLAUDE_DIR/commands"
        show_diff "hooks" "$DOTFILES_CLAUDE/hooks" "$CLAUDE_DIR/hooks"
        show_diff "settings.json" "$DOTFILES_CLAUDE/settings.json" "$CLAUDE_DIR/settings.json"
        ;;
    "sync")
        info "Syncing Claude configuration from dotfiles to ~/.claude...\n"
        
        # Show what will change
        if ! show_status >/dev/null 2>&1; then
            echo -e "\n${YELLOW}The following files will be updated:${NC}"
            show_status | grep "different" || true
            echo ""
            read -p "Continue? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Sync cancelled\n"
                exit 0
            fi
        fi
        
        # Run the install script which handles backup and copy
        "$DOTFILES_CLAUDE/install.sh"
        ;;
    "backup")
        create_backup
        ;;
    *)
        echo "Usage: $0 {status|diff|sync|backup}"
        echo ""
        echo "  status  - Show sync status of Claude configuration"
        echo "  diff    - Show differences between dotfiles and ~/.claude"
        echo "  sync    - Sync dotfiles to ~/.claude (with backup)"
        echo "  backup  - Create manual backup of ~/.claude"
        exit 1
        ;;
esac