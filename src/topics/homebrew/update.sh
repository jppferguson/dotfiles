#!/bin/sh
#
# Update homebrew
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Updating Homebrew"

brew bundle --global

# Per-machine extras (gitignored), layered on top of the shared Brewfile
BREWFILE_LOCAL="$DOTFILES/src/topics/homebrew/Brewfile.local"
if [ -f "$BREWFILE_LOCAL" ]; then
  brew bundle --file="$BREWFILE_LOCAL"
fi

brew update && brew upgrade

# And we're done
print_block_end
