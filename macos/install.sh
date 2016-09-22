#!/bin/sh
#
# Set macOS defaults
#
set -e

# Include the general functions
. ./functions/general

# Run the set-defaults script
$DOTFILES/macos/set-defaults.sh
