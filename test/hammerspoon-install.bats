#!/usr/bin/env bats
#
# Covers src/topics/hammerspoon/install.sh with brew stubbed on PATH, so
# nothing is installed. Whether the app is "installed" is driven by the stub's
# `list` exit status.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export DOTFILES="$REPO"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/brew" <<'STUB'
#!/bin/sh
echo "brew $*" >> "$BATS_TEST_TMPDIR/brew.log"
[ "$1" = list ] && exit "${BREW_LIST_STATUS:-1}"
exit 0
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/brew"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "hammerspoon install.sh: does not brew install when the cask is already installed" {
  BREW_LIST_STATUS=0 run bash "$REPO/src/topics/hammerspoon/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Hammerspoon is already installed"* ]]
  ! grep -q "brew install" "$BATS_TEST_TMPDIR/brew.log"
}

@test "hammerspoon install.sh: brew installs when neither the app nor the cask is present" {
  [ ! -d /Applications/Hammerspoon.app ] || skip "Hammerspoon.app is installed on this machine"
  BREW_LIST_STATUS=1 run bash "$REPO/src/topics/hammerspoon/install.sh"
  [ "$status" -eq 0 ]
  grep -q "brew install hammerspoon" "$BATS_TEST_TMPDIR/brew.log"
}
