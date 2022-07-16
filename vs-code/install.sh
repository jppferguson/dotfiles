#!/bin/sh
#
# Install VS Code Preferences
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing VS Code Preferences";

# symlink settings in
VS_CODE_DIR="${HOME}/Library/Application Support/Code"

# make sure file exists first
mkdir -p "${VS_CODE_DIR}"

# backup old settings folder
if [ -f "${VS_CODE_DIR}/User" ]; then
	mv "${VS_CODE_DIR}/User" "${VS_CODE_DIR}/User.backup"
fi

# symlink the User folder
ln -s "${DOTFILES}/vs-code/User" "${VS_CODE_DIR}"

print_block_end
