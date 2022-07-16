#!/bin/sh
#
# Check for macOS updates
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Checking for macOS updates";

# Don't try to update non-Macs
if test ! "$(uname)" = "Darwin"; then
  print_line "Not a Mac... exiting!"
  exit 0
fi

sudo softwareupdate -i -a

print_block_end

# Run the set-defaults script
# $DOTFILES/macos/set-defaults.sh
