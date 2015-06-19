#!/bin/sh
#
# Install required fonts
#
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing Fonts"

# Because OSX doesn't let you install fonts by symlink,
# lets rsync the folder, keeping things in sync

OSX_FONTS_DIR=~/Library/Fonts/dotfiles-fonts
DOTFILES_FONTS_DIR="$DOTFILES/fonts"

# do it
rsync -avz --exclude-from $DOTFILES_FONTS_DIR/rsync-exclude $DOTFILES_FONTS_DIR/ $OSX_FONTS_DIR
