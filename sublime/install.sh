#!/bin/sh
#
# Setup a machine for Sublime Text 3
#
###############################################################################

# Include the general functions
. ./functions/general

print_block "Installing Sublime Text Preferences";

# symlink settings in
SUBLIME_DIR="${HOME}/Library/Application\ Support/Sublime\ Text\ 3/Packages"

# make sure file exists first
mkdir -p "${SUBLIME_DIR}"

# backup old settings folder
mv "${SUBLIME_DIR}/User" "${SUBLIME_DIR}/User.backup"

# symlink the User folder
ln -s "${DOTFILES}/sublime/User" "${SUBLIME_DIR}"

print_block_end
