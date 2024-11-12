#!/bin/sh
#
# Check for macOS updates
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Checking for macOS updates";

# Don't try to update non-Macs
if test ! "$(uname)" = "Darwin"; then
  print_line "Not a Mac..." "exiting!"
  exit 0
fi

print_block_end

# Run the set-defaults script
$DOTFILES/src/topics/macos/set-defaults.sh
