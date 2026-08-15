#!/usr/bin/env bash
#
# Install Herdr configuration via a symlink into ~/.config/herdr.
# Only config.toml is linked - the rest of ~/.config/herdr (plugins/,
# session.json, sockets, logs, .plugins.lock) is local runtime/install
# state, so the directory is never symlinked wholesale.
#

. $DOTFILES/src/functions/general

HERDR_DIR="$HOME/.config/herdr"
DOTFILES_HERDR="$DOTFILES/src/topics/herdr"
BACKUP_DIR="$HERDR_DIR/backups/$(date +%Y-%m-%d-%H%M%S)"

mkdir -p "$HERDR_DIR"

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

    # Back up a real (non-symlink) file before replacing it
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        info "Backed up $dst to $BACKUP_DIR/"
    fi

    ln -sfn "$src" "$dst"
    print_success "Linked $dst -> $src"
}

info "Installing Herdr configuration (symlink)..."

link_item "$DOTFILES_HERDR/config.toml" "$HERDR_DIR/config.toml"

print_success "Herdr configuration installed"
