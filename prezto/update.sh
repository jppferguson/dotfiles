#!/bin/zsh
#
# Update prezto
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Checking for Prezto Updates";

PREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"

cd $PREZTO_DIR
git pull
git submodule sync --recursive
git submodule update --init --recursive
