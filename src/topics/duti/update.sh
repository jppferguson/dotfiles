#!/bin/sh
#
# Setup file associations
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Updating duti"

if ! command_exists duti; then
  print_error "ERROR: duti is missing. Install it with: brew install duti"
  exit 1
fi

# Update file associations
duti -v "${DOTFILES}/src/topics/duti/duti"
