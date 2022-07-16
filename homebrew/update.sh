#!/bin/sh
#
# Update homebrew
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Updating Homebrew"

brew bundle --global

brew update && brew upgrade

# And we're done
print_block_end
