#!/bin/sh
#
# Setup file associations
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing duti"

# Update file associations
sh $DOTFILES/duti/update.sh -s
