#!/bin/sh
#
# Install Homebrew
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing Homebrew"

# Check for Homebrew
if ! command_exists brew; then

  print_line "If nothing is moving for a while, try hitting" "Return"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

else
  print_error "Homebrew already installed"
fi

# Run updates
$DOTFILES/homebrew/update.sh

# And we're done
print_block_end
