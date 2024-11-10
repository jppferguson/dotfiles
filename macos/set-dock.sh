#!/bin/sh

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "/System/Applications/Notion.app"
dockutil --no-restart --add "/System/Applications/Notion Calendar.app"
dockutil --no-restart --add "/System/Applications/Notion Calendar.app"
dockutil --no-restart --add "/Applications/Spotify.app"

killall Dock