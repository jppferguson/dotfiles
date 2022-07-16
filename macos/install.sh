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
. $DOTFILES/functions/general

# Run the set-defaults script
$DOTFILES/macos/set-defaults.sh
