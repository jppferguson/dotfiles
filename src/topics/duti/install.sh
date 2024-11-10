#!/bin/sh
#
# Setup file associations
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing duti"

# Update file associations
sh $DOTFILES/src/topics/duti/update.sh -s
