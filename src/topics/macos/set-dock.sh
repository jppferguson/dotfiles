#!/bin/sh

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "/Applications/Notion.app"
dockutil --no-restart --add "/Applications/Notion Calendar.app"
dockutil --no-restart --add "/Applications/iTerm2.app"
dockutil --no-restart --add "/Applications/Spotify.app"

killall Dock