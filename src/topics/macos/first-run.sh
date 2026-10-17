#!/usr/bin/env bash
#
# One-time macOS setup that cannot be expressed as a `defaults write`.
#
# MANUAL: run this by hand on a new machine (`bash $DOTFILES/src/topics/macos/first-run.sh`).
# It is deliberately not called by `dot macos`, set-defaults.sh or any installer,
# because it deletes Launchpad data, reindexes Spotlight and needs sudo.
#
# Persistent preferences belong in defaults/*.yaml instead.

. "$DOTFILES/src/functions/general"

print_block "macOS first-run setup"

# Reset Launchpad, but keep the desktop wallpaper intact
find "${HOME}/Library/Application Support/Dock" -maxdepth 1 -name "*-*.db" -delete

# Show the ~/Library folder
chflags nohidden "${HOME}/Library"
xattr -d com.apple.FinderInfo "${HOME}/Library" 2> /dev/null || true

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Remove duplicates in the “Open With” menu
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Set the timezone; see `systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/London" > /dev/null

# Disable Spotlight indexing for any volume that gets mounted and has not yet
# been indexed before. Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing
# any volume. This targets a path rather than a preferences domain, so it
# cannot live in defaults/spotlight.yaml.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1 || true
# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null
# Rebuild the index from scratch
sudo mdutil -E / > /dev/null

print_block_end
