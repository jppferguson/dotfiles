#!/usr/bin/env bats
#
# Covers src/script/setup with uname, xcode-select, brew, git, curl and sleep
# stubbed on PATH, so nothing is installed, cloned or downloaded. Each stub
# logs its arguments to $BATS_TEST_TMPDIR/calls.log.

SETUP="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/src/script/setup"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export DOTFILES="$HOME/.dotfiles"
  export STUB_UNAME=Darwin
  mkdir -p "$HOME" "$BATS_TEST_TMPDIR/bin"

  stub uname 'echo "$STUB_UNAME"'
  stub xcode-select '[ "$1" != -p ] || [ -n "${STUB_CLT:-}" ]'
  stub brew ''
  stub curl ''
  stub sleep 'touch "$BATS_TEST_TMPDIR/clt-ready"'
  # A clone creates the target with a bootstrap that just records it ran
  stub git '[ "$1" = clone ] && mkdir -p "$3/.git" "$3/src/script" && printf "#!/bin/sh\necho bootstrap >> \"\$BATS_TEST_TMPDIR/calls.log\"\n" > "$3/src/script/bootstrap" && chmod +x "$3/src/script/bootstrap"; true'
  export PATH="$BATS_TEST_TMPDIR/bin:/usr/bin:/bin"
}

# stub() <command> <body>
#######################################
stub() {
  printf '#!/bin/bash\necho "%s $*" >> "$BATS_TEST_TMPDIR/calls.log"\n%s\n' "$1" "$2" > "$BATS_TEST_TMPDIR/bin/$1"
  chmod +x "$BATS_TEST_TMPDIR/bin/$1"
}

@test "setup: exits non-zero on Linux and points at the Raspberry Pi epic" {
  STUB_UNAME=Linux run bash "$SETUP"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Linux is not supported yet"* ]]
  [[ "$output" == *"c947aa29"* ]]
  ! grep -qE '^(xcode-select|git|curl) ' "$BATS_TEST_TMPDIR/calls.log"
}

@test "setup: with the tools and Homebrew present, clones and runs bootstrap" {
  STUB_CLT=1 run bash "$SETUP"
  [ "$status" -eq 0 ]
  ! grep -q '^xcode-select --install' "$BATS_TEST_TMPDIR/calls.log"
  ! grep -q '^curl ' "$BATS_TEST_TMPDIR/calls.log"
  grep -q "^git clone https://github.com/jppferguson/dotfiles.git $DOTFILES" "$BATS_TEST_TMPDIR/calls.log"
  grep -qx bootstrap "$BATS_TEST_TMPDIR/calls.log"
}

@test "setup: with ~/.dotfiles already cloned, pulls instead of cloning" {
  mkdir -p "$DOTFILES/.git" "$DOTFILES/src/script"
  printf '#!/bin/sh\necho bootstrap >> "$BATS_TEST_TMPDIR/calls.log"\n' > "$DOTFILES/src/script/bootstrap"
  chmod +x "$DOTFILES/src/script/bootstrap"

  STUB_CLT=1 run bash "$SETUP"
  [ "$status" -eq 0 ]
  grep -q "^git -C $DOTFILES pull --ff-only" "$BATS_TEST_TMPDIR/calls.log"
  ! grep -q '^git clone' "$BATS_TEST_TMPDIR/calls.log"
  grep -qx bootstrap "$BATS_TEST_TMPDIR/calls.log"
}

@test "setup: without the tools, runs xcode-select --install and waits for them" {
  stub xcode-select '[ "$1" != -p ] || [ -e "$BATS_TEST_TMPDIR/clt-ready" ]'

  run bash "$SETUP"
  [ "$status" -eq 0 ]
  grep -q '^xcode-select --install' "$BATS_TEST_TMPDIR/calls.log"
  grep -q '^sleep 5' "$BATS_TEST_TMPDIR/calls.log"
  grep -qx bootstrap "$BATS_TEST_TMPDIR/calls.log"
}

@test "setup: without Homebrew, downloads and runs the official installer" {
  rm "$BATS_TEST_TMPDIR/bin/brew"
  # The "installer" puts brew back on PATH, so setup never looks in the real
  # /opt/homebrew of the machine running the tests
  stub curl 'echo "echo installer >> \"\$BATS_TEST_TMPDIR/calls.log\"; cp \"\$BATS_TEST_TMPDIR/bin/curl\" \"\$BATS_TEST_TMPDIR/bin/brew\""'

  STUB_CLT=1 run bash "$SETUP"
  [ "$status" -eq 0 ]
  grep -q '^curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' "$BATS_TEST_TMPDIR/calls.log"
  grep -qx installer "$BATS_TEST_TMPDIR/calls.log"
  grep -qx bootstrap "$BATS_TEST_TMPDIR/calls.log"
}
