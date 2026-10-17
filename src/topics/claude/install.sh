#!/usr/bin/env bash
#
# Install Claude Code configuration via per-item symlinks into ~/.claude.
# Symlinking individual items (never the whole directory) keeps runtime
# state (projects/, history.jsonl, caches) out of the repo while making
# every config tweak instantly visible in git.
#
# Decision (17 Oct 2026): permissions.defaultMode and skipAutoPermissionPrompt live in the gitignored settings.local.json, not the public settings.json, so the repo does not advertise an auto-mode, prompt-free posture.
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

# True when the live settings.json is identical (after jq -S normalisation) to
# the merge merge-settings.sh is about to write. Uses the same expression.
live_matches_merge() {
    local live="$1"
    local merged

    if [ -f "$DOTFILES_CLAUDE/settings.local.json" ]; then
        merged=$(jq -S -s '.[0] * .[1]' "$DOTFILES_CLAUDE/settings.json" "$DOTFILES_CLAUDE/settings.local.json") || return 1
    else
        merged=$(jq -S . "$DOTFILES_CLAUDE/settings.json") || return 1
    fi
    [ "$(jq -S . "$live" 2>/dev/null)" = "$merged" ]
}

# settings.json is a merge, not a symlink: src/topics/claude/settings.local.json
# is a gitignored, per-machine overlay (PATH, worktree dirs, autoMode infra
# notes) that must never reach the public repo. If present, it's deep-merged
# over the public settings.json (local wins) into a generated ~/.claude/settings.json
# by merge-settings.sh, kept live thereafter by the claude-settings-sync
# LaunchAgent installed below (WatchPaths on both source files - editing
# either one re-merges within seconds, no manual re-run needed). The one
# direction that stays manual: an edit made live (e.g. via `/config`) does
# NOT propagate back to the two source files - split it back by hand.
merge_claude_settings() {
    local dst="$CLAUDE_DIR/settings.json"

    if [ -e "$dst" ] && [ ! -L "$dst" ] && [ ! -f "$DOTFILES_CLAUDE/settings.json" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        info "Backed up $dst to $BACKUP_DIR/"
    elif [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ] && ! live_matches_merge "$dst"; then
        # Copy rather than move: merge-settings.sh replaces the live file itself.
        # mktemp keeps two syncs in the same second from overwriting each other,
        # and a failed copy aborts before the live file is replaced.
        local backup
        if ! mkdir -p "$BACKUP_DIR" || ! backup=$(mktemp "$BACKUP_DIR/settings.json.XXXXXX") || ! cp "$dst" "$backup"; then
            print_error "Could not back up $dst to $BACKUP_DIR, leaving it untouched" ""
            return 1
        fi
        info "Live $dst differs from the merge; backed up to $backup"
        info "It holds changes not in settings.json or settings.local.json - split them back by hand if you want to keep them"
    fi

    bash "$DOTFILES_CLAUDE/merge-settings.sh"
    print_success "Merged $dst from settings.json + settings.local.json"
}

# Installs (or reloads) the LaunchAgent that keeps ~/.claude/settings.json
# in sync whenever settings.json or settings.local.json changes.
install_claude_settings_sync() {
    local plist_dst="$HOME/Library/LaunchAgents/com.jppferguson.claude-settings-sync.plist"
    local plist_tmp="$plist_dst.tmp"

    mkdir -p "$HOME/Library/LaunchAgents"
    # Render to a temp file and mv over the destination so an older symlink
    # to the repo is replaced rather than written through
    if ! bash "$DOTFILES_CLAUDE/render-plist.sh" > "$plist_tmp" || [ ! -s "$plist_tmp" ]; then
        rm -f "$plist_tmp"
        print_error "Failed to render $plist_dst, leaving the existing plist in place" ""
        return 1
    fi
    mv -f "$plist_tmp" "$plist_dst"
    print_success "Rendered $plist_dst"

    launchctl bootout "gui/$(id -u)" "$plist_dst" >/dev/null 2>&1 || true
    if launchctl bootstrap "gui/$(id -u)" "$plist_dst" 2>/dev/null; then
        print_success "claude-settings-sync LaunchAgent loaded"
    else
        print_error "Failed to load claude-settings-sync LaunchAgent" ""
    fi
}

info "Installing Claude Code configuration (symlinks)..."

merge_claude_settings || exit 1
# Keep linking the rest, but remember a failed render so we exit non-zero
sync_status=0
install_claude_settings_sync || sync_status=1
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

if [ "$sync_status" -ne 0 ]; then
    exit "$sync_status"
fi

print_success "Claude configuration installed"
