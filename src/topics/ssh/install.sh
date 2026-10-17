#!/bin/sh
#
# Prepare ~/.ssh for the shared config: the ControlPath socket directory and
# private permissions. Safe to re-run.
#
###############################################################################
set -e

# Include the general functions
. "$DOTFILES/src/functions/general"

print_block "Setting up ~/.ssh"

mkdir -p "$HOME/.ssh/sockets"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets"

# config.local holds private hosts and is deliberately untracked
if [ -f "$HOME/.ssh/config.local" ]; then
  chmod 600 "$HOME/.ssh/config.local"
fi

print_success "$HOME/.ssh/sockets ready"
