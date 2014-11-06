#!/bin/sh
# Update z
set -e

echo "\nUpdating z"
cd "$VENDOR/z" && git up
