#!/bin/sh
#
# Update z
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Updating z";

cd "$VENDOR/z" && git up
