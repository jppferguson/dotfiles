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

# settings.json is a merge, not a symlink: src/topics/claude/settings.local.json
# is a gitignored, per-machine overlay (PATH, worktree dirs, autoMode infra
# notes) that must never reach the public repo. If present, it's deep-merged
# over the public settings.json (local wins) into a generated ~/.claude/settings.json.
# Because this is generated, an edit made live (e.g. via `/config`) does NOT
# propagate back automatically - split it back into the two source files by
# hand, the same way a symlinked item would need no such step.
merge_claude_settings() {
    local public="$DOTFILES_CLAUDE/settings.json"
    local overlay="$DOTFILES_CLAUDE/settings.local.json"
    local dst="$CLAUDE_DIR/settings.json"

    if [ ! -e "$public" ]; then
        print_error "Source not found: $public"
        return 1
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        info "Backed up $dst to $BACKUP_DIR/"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi

    if [ -f "$overlay" ]; then
        jq -s '.[0] * .[1]' "$public" "$overlay" > "$dst"
        print_success "Merged $dst <- $public + $overlay"
    else
        cp "$public" "$dst"
        info "No $overlay found - installed $dst from public settings only"
    fi
}

info "Installing Claude Code configuration (symlinks)..."

merge_claude_settings
link_item "$DOTFILES_CLAUDE/statusline.sh" "$CLAUDE_DIR/statusline.sh"
link_item "$DOTFILES_CLAUDE/agents"        "$CLAUDE_DIR/agents"

# ~/.claude/hooks stays a real directory (machine-local hooks, e.g. herdr's,
# live there too) - link each repo-tracked hook into it individually.
mkdir -p "$CLAUDE_DIR/hooks"
for hook in "$DOTFILES_CLAUDE"/hooks/*; do
    link_item "$hook" "$CLAUDE_DIR/hooks/$(basename "$hook")"
done

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
