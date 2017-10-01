#!./libs/bats/bin/bats

# bats helpers
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# functions to test
. ~/.dotfiles/functions/general

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
  assert_success
}

@test "inArray(): Returns 0 when string is NOT in array" {
  arrayUnderTest=(aa bb)
  run inArray "cc" "${arrayUnderTest[@]}"
  assert_failure
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

@test "print_fancy(): Prints large text block" {
  run print_fancy "testing"
  assert_output --partial "\__\___/__/\__|_|_||_\__, |"
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
  assert_success
}

@test "command_exists(): Returns 0 for a command that does NOT exist" {
  run command_exists "notARealCommand"
  assert_failure
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

@test "uncomment(): TBC" {
  skip
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

@test "cask_install(): TBC" {
  skip
}


# cask_reinstall()
#######################################

@test "cask_reinstall(): TBC" {
  skip
}


# source_file()
#######################################

@test "source_file(): TBC" {
  skip
}


# source_files()
#######################################

@test "source_files(): TBC" {
  skip
}
