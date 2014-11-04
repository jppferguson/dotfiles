#!/bin/sh
# Setup a machine for Sublime Text 3
set -x

# symlink settings in
SUBLIME_DIR=~/Library/Application\ Support/Sublime\ Text\ 3/Packages
mv "$SUBLIME_DIR/User" "$SUBLIME_DIR/User.backup"
ln -s "$DOTFILES/sublime/User" "$SUBLIME_DIR"
