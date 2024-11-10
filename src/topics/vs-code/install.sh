#!/bin/sh
#
# Install VS Code Preferences
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing VS Code Preferences";

# symlink settings in
VS_CODE_DIR="${HOME}/Library/Application Support/Code"
VS_CODE_INSIDERS_DIR="${HOME}/Library/Application Support/Code - Insiders"
CUR_UNIX="`date +%s`"

installVSCode () {
	# make sure file exists first
	mkdir -p "${1}"

	links=("User/settings.json" "User/keybindings.json")
	for link in "${links[@]}"; do
		# Backup
		FILE_PATH="${1}/${link}"
		FILE_BACKUP="${1}/_backup/${CUR_UNIX}/${link}"
		if [[ -f "$FILE_PATH" ]]; then
			mkdir -p "${FILE_BACKUP}"
			mv "${1}/${link}" "${FILE_BACKUP}"
		fi
		# Link
		ln -s "${DOTFILES}/src/topics/vs-code/${link}" "${1}/${link}"
	done
}

installVSCode "${VS_CODE_DIR}"
installVSCode "${VS_CODE_INSIDERS_DIR}"

print_block_end
