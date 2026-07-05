#!/usr/bin/env bash
#
# Install Claude Code configuration via per-item symlinks into ~/.claude.
# Symlinking individual items (never the whole directory) keeps runtime
# state (projects/, history.jsonl, caches) out of the repo while making
# every config tweak instantly visible in git.
#

. $DOTFILES/src/functions/general

CLAUDE_DIR="$HOME/.claude"
DOTFILES_CLAUDE="$DOTFILES/src/topics/claude"
AGENTRC="$DOTFILES/src/topics/agentrc.symlink"
BACKUP_DIR="$CLAUDE_DIR/backups/$(date +%Y-%m-%d-%H%M%S)"

mkdir -p "$CLAUDE_DIR"

# Symlink a source into place, backing up any pre-existing real file/dir.
link_item() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        print_error "Source not found: $src"
        return 1
    fi

    # Already correctly linked
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        info "Already linked: $dst"
        return 0
    fi

    # Back up a real (non-symlink) file or directory before replacing it
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        info "Backed up $dst to $BACKUP_DIR/"
    fi

    ln -sfn "$src" "$dst"
    print_success "Linked $dst -> $src"
}

info "Installing Claude Code configuration (symlinks)..."

link_item "$DOTFILES_CLAUDE/settings.json" "$CLAUDE_DIR/settings.json"
link_item "$DOTFILES_CLAUDE/statusline.sh" "$CLAUDE_DIR/statusline.sh"
link_item "$DOTFILES_CLAUDE/agents"        "$CLAUDE_DIR/agents"

# Shared cross-agent assets live in ~/.agentrc (itself a symlink into this repo).
# ~/.claude/skills stays a real directory (other tools, e.g. gstack, install
# their own skills there) - link each shared skill into it individually.
mkdir -p "$CLAUDE_DIR/skills"
for skill in "$AGENTRC"/skills/*/; do
    link_item "${skill%/}" "$CLAUDE_DIR/skills/$(basename "$skill")"
done

link_item "$AGENTRC/AGENTS.md" "$CLAUDE_DIR/CLAUDE.md"

# Wire the same global instructions into other agents when they're installed
[ -d "$HOME/.codex" ]  && link_item "$AGENTRC/AGENTS.md" "$HOME/.codex/AGENTS.md"
[ -d "$HOME/.gemini" ] && link_item "$AGENTRC/AGENTS.md" "$HOME/.gemini/GEMINI.md"
[ -d "$HOME/.config/opencode" ] && link_item "$AGENTRC/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"

# Clean up old backups (keep last 5)
if [ -d "$CLAUDE_DIR/backups" ]; then
    ls -t "$CLAUDE_DIR/backups" | tail -n +6 | while read -r old; do
        rm -rf "$CLAUDE_DIR/backups/$old"
    done
fi

print_success "Claude configuration installed"
