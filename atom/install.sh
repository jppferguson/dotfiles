#!/bin/sh
#
# Setup a machine for Atom
#
###############################################################################

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing Atom";

# Check for Atom shell tools
if ! command_exists apm; then

  # No Atom shell tools :(
  print_error "Atom shell tools not installed. Please install and try again."

else

  # Install package sync
  apm install package-sync

  # Sync packages
  atom package-sync:sync
fi

print_block_end
