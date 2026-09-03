#!/usr/bin/env bash
#
# Update required fonts
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Updating fonts"

# install fontconfig
brew install fontconfig

# Because OSX doesn't let you install fonts by symlink,
# lets rsync the folder, keeping things in sync
OSX_FONTS_DIR=~/Library/Fonts/Dotfiles
DOTFILES_FONTS_DIR="$DOTFILES/src/topics/fonts"

rsync -avz --exclude-from $DOTFILES_FONTS_DIR/rsync-exclude $DOTFILES_FONTS_DIR/ $OSX_FONTS_DIR
