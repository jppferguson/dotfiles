#!/bin/sh
#
# git clone https://github.com/robbyrussell/oh-my-zsh
# oh-my-zsh is an open source, community-driven framework for managing your Zsh configuration.
# It comes bundled with a ton of helpful functions, helpers, plugins, themes, and a few things that make you shout…
# “OH MY ZSHELL!”
#

# Include the general functions
. ./functions/general

if [ ! -d "$VENDOR/oh-my-zsh" ]; then
  print_block "Installing oh-my-zsh"
  cd $VENDOR
  git clone https://github.com/robbyrussell/oh-my-zsh.git
  chmod +x $VENDOR/oh-my-zsh/oh-my-zsh.sh

  # Install Theme
  cp -R $DOTFILES/oh-my-zsh/custom $VENDOR/oh-my-zsh-custom
else
  if [ -d "$ZSH" ]; then echo "\033[0;33mYou already have Oh My Zsh installed.\033[0m You'll need to remove $ZSH if you want to install"; else echo "Your oh-my-zsh instalation failed!"; fi
fi

exit 0
