#!/bin/sh
#
# Setup file associations
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Updating duti"

if ! command_exists duti; then
  print_error "Please install duti!"
fi

# Update file associations
duti -v "${DOTFILES}/duti/duti"
