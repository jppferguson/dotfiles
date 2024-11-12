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

# Run the set-defaults script
$DOTFILES/src/topics/macos/set-defaults.sh
