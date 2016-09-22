#!/bin/sh
#
# Check for macOS updates
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Checking for macOS updates";

softwareupdate -l
# we're not really doing anything for now, so just list them out

print_block_end

# Run the set-defaults script
# $DOTFILES/macos/set-defaults.sh
