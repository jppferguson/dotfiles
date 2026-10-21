#!/usr/bin/env bash
#
# Rela guard: the codex wrapper needs no install (path.zsh puts bin/ on PATH) and the Claude Code hook ships with
# the claude topic. This links the Hermes plugin into ~/.hermes/plugins and enables it, on machines that run Hermes.

. $DOTFILES/src/functions/general

HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
PLUGIN_SRC="$DOTFILES/src/topics/rela/hermes/rela-guard"
PLUGIN_DST="$HERMES_DIR/plugins/rela-guard"

if [ ! -d "$HERMES_DIR" ]; then
    info "No $HERMES_DIR here, skipping the Hermes plugin"
    return 0 2>/dev/null || exit 0
fi

mkdir -p "$HERMES_DIR/plugins"
if [ -L "$PLUGIN_DST" ] && [ "$(readlink "$PLUGIN_DST")" = "$PLUGIN_SRC" ]; then
    info "Already linked: $PLUGIN_DST"
elif [ -e "$PLUGIN_DST" ] && [ ! -L "$PLUGIN_DST" ]; then
    print_error "$PLUGIN_DST exists and is not a symlink; move it aside and re-run"
    return 1 2>/dev/null || exit 1
else
    ln -sfn "$PLUGIN_SRC" "$PLUGIN_DST"
    print_success "Linked $PLUGIN_DST -> $PLUGIN_SRC"
fi

if command -v hermes >/dev/null 2>&1; then
    hermes plugins enable rela-guard >/dev/null && print_success "Enabled the rela-guard Hermes plugin"
    info "Restart Hermes (gateway and desktop) to load it"
else
    print_error "hermes not on PATH: run 'hermes plugins enable rela-guard' once it is"
fi
