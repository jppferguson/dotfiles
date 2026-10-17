#!./libs/bats/bin/bats

# functions to test
. $PWD/src/functions/general

# Minimal self-contained assertion helpers (no bats-assert/bats-support
# dependency - this repo has no submodule convention and the assertions
# needed here are a small, fixed set). Operate on bats' own $output/$lines.

assert_output () {
  if [ "$1" = "--partial" ]
  then
    [[ "$output" == *"$2"* ]]
  else
    [ "$output" = "$1" ]
  fi
}

assert_line () {
  local index= partial=false needle=
  while [ $# -gt 0 ]
  do
    case "$1" in
      --index)   index=$2; shift 2;;
      --partial) partial=true; shift;;
      *)         needle=$1; shift;;
    esac
  done

  if [ -n "$index" ]
  then
    local line="${lines[$index]}"
    if [ "$partial" = true ]
    then [[ "$line" == *"$needle"* ]]
    else [ "$line" = "$needle" ]
    fi
  else
    local line
    for line in "${lines[@]}"
    do
      if [ "$partial" = true ]
      then [[ "$line" == *"$needle"* ]] && return 0
      else [ "$line" = "$needle" ] && return 0
      fi
    done
    return 1
  fi
}

refute_line () {
  local partial=false needle=
  while [ $# -gt 0 ]
  do
    case "$1" in
      --partial) partial=true; shift;;
      *)         needle=$1; shift;;
    esac
  done

  local line
  for line in "${lines[@]}"
  do
    if [ "$partial" = true ]
    then [[ "$line" == *"$needle"* ]] && return 1
    else [ "$line" = "$needle" ] && return 1
    fi
  done
  return 0
}

# Colour assertion helpers
assert_red_text     () { assert_output --partial "31"; }
assert_green_text   () { assert_output --partial "32"; }
assert_yellow_text  () { assert_output --partial "33"; }
assert_blue_text    () { assert_output --partial "34"; }
assert_magenta_text () { assert_output --partial "35"; }
assert_cyan_text    () { assert_output --partial "36"; }
assert_white_text   () { assert_output --partial "37"; }


# inArray() <string> <array>
#######################################

@test "inArray(): Returns 1 when string IS in array" {
  arrayUnderTest=(aa bb)
  run inArray "bb" "${arrayUnderTest[@]}"
  [ "$status" -eq 0 ]
}

@test "inArray(): Returns 0 when string is NOT in array" {
  arrayUnderTest=(aa bb)
  run inArray "cc" "${arrayUnderTest[@]}"
  [ "$status" -eq 1 ]
}


# print_block() <string>
#######################################

@test "print_block(): Prints block surrounded by asterisks" {
  run print_block "testing"
  assert_output --partial "*********"
  assert_output --partial "testing"
  assert_cyan_text
  assert_blue_text
}


# print_fancy() <string>
#######################################

@test "print_fancy(): Prints non-empty green output (figlet if installed, block fallback otherwise)" {
  run print_fancy "testing"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  assert_green_text
}


# print_block_end() <string>
#######################################

@test "print_block_end(): Prints asterisks length+1 of last print_block()" {
  print_block "testing output"
  run print_block_end
  assert_line --index 0 --partial "****************"
  assert_cyan_text
}

# print_line() <string>
#######################################

@test "print_line(): Prints line of text" {
  run print_line "testing output"
  assert_line --partial "testing output"
  assert_green_text
}


# print_warning() <string>
#######################################

@test "print_warning(): Prints warning text" {
  run print_warning "Some warning copy"
  assert_line --partial "Warning: "
  assert_line --partial "Some warning copy"
  assert_red_text
  assert_yellow_text
}


# print_task() <string>
#######################################

@test "print_task(): Prints task text" {
  run print_task "[info]" "Some task copy"
  assert_line --partial "[info] "
  assert_line --partial "Some task copy"
  assert_green_text
}


# print_error() <string>
#######################################

@test "print_error(): Prints error text" {
  run print_error "Some error text"
  assert_line --partial "Some error text"
  assert_red_text
  assert_yellow_text
}


# print_array() <array>
#######################################

@test "print_array(): Prints array items on new line per item" {
  arrayUnderTest=(aaa bbb ccc)
  run print_array "${arrayUnderTest[@]}"
  assert_line --index 0 "aaa"
  assert_line --index 1 "bbb"
  assert_line --index 2 "ccc"
}


# filter_array_include() <string> <array>
#######################################

@test "filter_array_include(): Removes items from array which do NOT contain substring when exclude is true" {
  arrayUnderTest=(aaa bbb ccc ddd)
  run filter_array_include "c" "${arrayUnderTest[@]}"
  assert_output "ccc"
}

# filter_array_exclude() <string> <array>
#######################################

@test "filter_array_exclude(): Removes items from array which contain substring when exclude is false" {
  arrayUnderTest=(item1 item2 item3)
  run filter_array_exclude "item1" "${arrayUnderTest[@]}"
  assert_output "item2 item3"
}


# command_exists() <string>
#######################################

@test "command_exists(): Returns 1 for a command that DOES exist" {
  run command_exists "grep"
  [ "$status" -eq 0 ]
}

@test "command_exists(): Returns 0 for a command that does NOT exist" {
  run command_exists "notARealCommand"
  [ "$status" -eq 1 ]
}


# info() <string>
#######################################

@test "info(): outputs string with colouring" {
    run info "testing"
    assert_line --partial "testing"
    assert_blue_text
}


# user() <string>
#######################################

@test "user(): outputs string with colouring" {
    run user "testing"
    assert_line --partial "testing"
    assert_yellow_text
}


# print_success()
#######################################

@test "print_success(): outputs string with colouring" {
    run print_success "all systems go"
    assert_line --partial "OK"
    assert_line --partial "all systems go"
    assert_green_text
}


# print_fail()
#######################################

@test "print_fail(): outputs string with colouring" {
    run print_fail "something went wrong"
    assert_line --partial "FAIL"
    assert_line --partial "something went wrong"
    assert_red_text
}


# uncomment()
#######################################

@test "uncomment(): Uncomments a matching line in a file" {
  # Stub sudo so the real sed edit runs as the test user against a temp file
  sudo () { "$@"; }

  local target="$BATS_TEST_TMPDIR/config"
  printf '#some_option true\nother_line\n' > "$target"

  uncomment "some_option" "$target"

  run cat "$target"
  assert_line "some_option true"
}


# verboseOut()
#######################################

@test "verboseOut(): Outputs string if verbose variable is truthy" {
  verbose=true
  run verboseOut "Some debug information"
  assert_line --partial "Some debug information"
  assert_yellow_text
}

@test "verboseOut(): Does not output string if verbose variable is not truthy" {
  verbose=false
  run verboseOut "Some debug information"
  refute_line --partial "Some debug information"
}

@test "verboseOut(): Does not output string if verbose variable is not set" {
  unset verbose
  run verboseOut "Some debug information"
  refute_line --partial "Some debug information"
}


# cask_install()
#######################################

@test "cask_install(): Invokes brew install --cask with the given args" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/brew" <<'EOF'
#!/usr/bin/env bash
echo "brew $*"
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/brew"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run cask_install "some-cask"
  assert_output --partial "brew install --cask some-cask"
}


# cask_reinstall()
#######################################

@test "cask_reinstall(): Invokes brew install --cask --force with the given args" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/brew" <<'EOF'
#!/usr/bin/env bash
echo "brew $*"
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/brew"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run cask_reinstall "some-cask"
  assert_output --partial "brew install --cask --force some-cask"
}


# source_file()
#######################################

@test "source_file(): Sources an existing file into the current shell" {
  local target="$BATS_TEST_TMPDIR/vars.sh"
  echo 'SOURCED_VAR=hello' > "$target"

  source_file "$target"

  [ "$SOURCED_VAR" = "hello" ]
}

@test "source_file(): Does nothing for a file that does not exist" {
  run source_file "$BATS_TEST_TMPDIR/does-not-exist.sh"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}


# source_files()
#######################################

@test "source_files(): Sources every file in the given array" {
  local first="$BATS_TEST_TMPDIR/first.sh"
  local second="$BATS_TEST_TMPDIR/second.sh"
  echo 'FIRST_VAR=one' > "$first"
  echo 'SECOND_VAR=two' > "$second"

  source_files "$first" "$second"

  [ "$FIRST_VAR" = "one" ]
  [ "$SECOND_VAR" = "two" ]
}


# prune_dead_links() <yes>
#######################################

setup_prune_fixtures () {
  PRUNE_TEST_HOME=$(mktemp -d)
  PRUNE_TEST_DOTFILES=$(mktemp -d)
  mkdir -p "$PRUNE_TEST_DOTFILES/src/topics/removed" "$PRUNE_TEST_HOME/.config"
}

teardown_prune_fixtures () {
  rm -rf "$PRUNE_TEST_HOME" "$PRUNE_TEST_DOTFILES"
}

@test "prune_dead_links(): reports none when no dangling symlinks exist" {
  setup_prune_fixtures
  HOME="$PRUNE_TEST_HOME" DOTFILES="$PRUNE_TEST_DOTFILES" run prune_dead_links
  [ "$status" -eq 0 ]
  assert_output --partial "no dangling"
  teardown_prune_fixtures
}

@test "prune_dead_links(): lists (but does not delete) a dangling \$DOTFILES symlink by default" {
  setup_prune_fixtures
  ln -s "$PRUNE_TEST_DOTFILES/src/topics/removed/gone.symlink" "$PRUNE_TEST_HOME/.gone"

  HOME="$PRUNE_TEST_HOME" DOTFILES="$PRUNE_TEST_DOTFILES" run prune_dead_links
  [ "$status" -eq 0 ]
  assert_output --partial "$PRUNE_TEST_HOME/.gone"
  [ -L "$PRUNE_TEST_HOME/.gone" ]
  teardown_prune_fixtures
}

@test "prune_dead_links(): removes exactly the dangling symlink when yes=true" {
  setup_prune_fixtures
  ln -s "$PRUNE_TEST_DOTFILES/src/topics/removed/gone.symlink" "$PRUNE_TEST_HOME/.gone"

  HOME="$PRUNE_TEST_HOME" DOTFILES="$PRUNE_TEST_DOTFILES" run prune_dead_links true
  [ "$status" -eq 0 ]
  [ ! -e "$PRUNE_TEST_HOME/.gone" ]
  [ ! -L "$PRUNE_TEST_HOME/.gone" ]
  teardown_prune_fixtures
}

@test "prune_dead_links(): leaves a valid \$DOTFILES symlink untouched" {
  setup_prune_fixtures
  echo "still here" > "$PRUNE_TEST_DOTFILES/src/topics/removed/kept.symlink"
  ln -s "$PRUNE_TEST_DOTFILES/src/topics/removed/kept.symlink" "$PRUNE_TEST_HOME/.kept"

  HOME="$PRUNE_TEST_HOME" DOTFILES="$PRUNE_TEST_DOTFILES" run prune_dead_links true
  [ "$status" -eq 0 ]
  refute_line --partial ".kept"
  [ -L "$PRUNE_TEST_HOME/.kept" ]
  teardown_prune_fixtures
}

@test "prune_dead_links(): ignores a dangling symlink whose target is outside \$DOTFILES" {
  setup_prune_fixtures
  local outside
  outside=$(mktemp -d)
  ln -s "$outside/gone-elsewhere" "$PRUNE_TEST_HOME/.unrelated"

  HOME="$PRUNE_TEST_HOME" DOTFILES="$PRUNE_TEST_DOTFILES" run prune_dead_links
  [ "$status" -eq 0 ]
  refute_line --partial ".unrelated"
  [ -L "$PRUNE_TEST_HOME/.unrelated" ]
  rm -rf "$outside"
  teardown_prune_fixtures
}
