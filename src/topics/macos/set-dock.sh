#!/usr/bin/env bash

. $DOTFILES/src/functions/general

if ! command_exists dockutil; then
  print_error "ERROR: dockutil is missing. Install it with: brew install dockutil"
  exit 1
fi

dockutil --no-restart --remove all

# Apps not installed on this machine are skipped rather than erroring
for app in "Toggl Track" "Mimestream" "Google Chrome" "Notion" "Notion Calendar" "iTerm" "Spotify"; do
  if [ -d "/Applications/$app.app" ]; then
    dockutil --no-restart --add "/Applications/$app.app"
  fi
done

killall Dock
