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
	print_task "Installing VSCode:" "${1}"
	links=("User/settings.json" "User/keybindings.json")
	for link in "${links[@]}"; do
		FILE_DIR="${1}/$(dirname "${link}")"
		# make sure directory exists first
		mkdir -p "${FILE_DIR}"

		# Backup
		FILE_PATH="${1}/${link}"
		FILE_BACKUP="${1}/_backup/${CUR_UNIX}/${link}"
		if [[ -f "$FILE_PATH" ]]; then
			print_line "Backing up existing:" "${link}"
			FILE_BACKUP_DIR="$(dirname "${FILE_BACKUP}")"
			mkdir -p "${FILE_BACKUP_DIR}"
			mv "${1}/${link}" "${FILE_BACKUP}"
		fi
		# Link
		print_line "Linking:" "${link}"
		ln -s "${DOTFILES}/src/topics/vs-code/${link}" "${1}/${link}"
	done
}

installVSCode "${VS_CODE_DIR}"
installVSCode "${VS_CODE_INSIDERS_DIR}"

print_block_end
