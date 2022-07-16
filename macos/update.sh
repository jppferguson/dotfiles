#!/bin/sh
#
# Check for macOS updates
#
###############################################################################
set -e

# Don't try to update non-Macs
if test ! "$(uname)" = "Darwin"
  then
  exit 0
fi

# Include the general functions
. $DOTFILES/functions/general

print_block "Checking for macOS updates";

sudo softwareupdate -i -a

print_block_end

# Run the set-defaults script
# $DOTFILES/macos/set-defaults.sh
