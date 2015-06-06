#!/bin/sh
#
# Set OSX defaults
#
set -e

# Include the general functions
. ./functions/general

# Run the set-defaults script
$DOTFILES/osx/set-defaults.sh
