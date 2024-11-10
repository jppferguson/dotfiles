#!/bin/sh
#
# Set macOS defaults
#
###############################################################################
set -e

if [[ -z $DOTFILES ]]; then
  echo "The dotfiles environment variable hasn't been initialised yet."
  exit 1
fi

# Include the general functions
. $DOTFILES/src/functions/general

print_warning "NOTE: if you get 'Could not write domain...' errors below, you may need to add your terminal app (e.g. Terminal.app, iTerm2) to System Preferences -> Privacy -> Full Disk Access"

# Run the set-defaults script
$DOTFILES/src/topics/macos/set-defaults.sh
