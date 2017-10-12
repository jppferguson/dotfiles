#!/bin/sh
#
# Prezto is the configuration framework for Zsh; it enriches the command line interface environment
# with sane defaults, aliases, functions, auto completion, and prompt themes.
#

# Include the general functions
. ./functions/general

PREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"

if [ ! -d "${PREZTO_DIR}" ]; then
  print_block "Installing prezto"
  cd $HOME
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${PREZTO_DIR}"

else
  if [ -d "${PREZTO_DIR}" ]; then
    echo "\033[0;33mYou already have Prezto! YAY!";
    echo "\033[0mYou'll need to remove $PREZTO_DIR if you want to re-install.";
  else
    echo "Your prezto instalation failed!";
  fi
fi

exit 0
