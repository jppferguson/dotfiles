#!/usr/bin/env bash
#
# Install Claude configuration by copying files
# (Using copy instead of symlinks due to Claude Code bug: https://github.com/anthropics/claude-code/issues/764)
#

# Include the general functions
. $DOTFILES/src/functions/general

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create ~/.claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Create backup directory with timestamp
BACKUP_DIR="$HOME/.claude/backups/$(date +%Y-%m-%d-%H%M%S)"

# Function to backup a file or directory if it exists
backup_if_exists() {
    local src="$1"
    local name="$2"
    
    if [ -e "$src" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$src" "$BACKUP_DIR/"
        info "Backed up existing $name to $BACKUP_DIR/"
        return 0
    fi
    return 1
}

# Function to copy claude files
copy_claude_files() {
    local src="$1"
    local dst="$2"
    local name="$3"
    
    if [ -e "$src" ]; then
        # Backup existing if it exists
        backup_if_exists "$dst" "$name"
        
        # Remove existing and copy new
        rm -rf "$dst"
        cp -r "$src" "$dst"
        print_success "Copied $name to $dst"
        return 0
    else
        print_error "Source $name not found at $src"
        return 1
    fi
}

info "Installing Claude configuration..."

# Copy commands directory
copy_claude_files "$DOTFILES/src/topics/claude/commands" "$HOME/.claude/commands" "commands"

# Copy hooks directory  
copy_claude_files "$DOTFILES/src/topics/claude/hooks" "$HOME/.claude/hooks" "hooks"

# Copy settings.json
copy_claude_files "$DOTFILES/src/topics/claude/settings.json" "$HOME/.claude/settings.json" "settings.json"

# Clean up old backups (keep last 5)
if [ -d "$HOME/.claude/backups" ]; then
    cd "$HOME/.claude/backups"
    ls -t | tail -n +6 | xargs rm -rf 2>/dev/null || true
    info "Cleaned up old backups (keeping last 5)"
fi

if [ -d "$BACKUP_DIR" ]; then
    info "Backups created in: $BACKUP_DIR"
fi

print_success "Claude configuration installed successfully"
info "Note: Using copy method due to Claude Code symlink bug"
info "Bug tracking: https://github.com/anthropics/claude-code/issues/764"