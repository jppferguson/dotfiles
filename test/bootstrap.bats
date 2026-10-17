#!/usr/bin/env bats
#
# Covers src/script/bootstrap's install_dotfiles/link_file symlink mapping.
# The bottom-of-file create_localrc/setup_gitconfig/install_dotfiles calls are
# guarded (BASH_SOURCE == $0) so sourcing this file only defines functions -
# it must never prompt for input or touch the real $HOME.

BOOTSTRAP="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/src/script/bootstrap"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  . "$BOOTSTRAP"
}

# install_dotfiles() <.symlink layout under DOTFILES_TOPIC_ROOT>
#######################################

@test "install_dotfiles(): links a bare name.symlink to \$HOME/.name" {
  DOTFILES_TOPIC_ROOT="$BATS_TEST_TMPDIR/topics"
  mkdir -p "$DOTFILES_TOPIC_ROOT/sometopic"
  echo content > "$DOTFILES_TOPIC_ROOT/sometopic/name.symlink"

  install_dotfiles

  [ -L "$HOME/.name" ]
  [ "$(readlink "$HOME/.name")" = "$DOTFILES_TOPIC_ROOT/sometopic/name.symlink" ]
}

@test "install_dotfiles(): links a nested subdir/file.symlink preserving structure under \$HOME" {
  DOTFILES_TOPIC_ROOT="$BATS_TEST_TMPDIR/topics"
  mkdir -p "$DOTFILES_TOPIC_ROOT/sometopic/subdir"
  echo content > "$DOTFILES_TOPIC_ROOT/sometopic/subdir/file.symlink"

  install_dotfiles

  [ -L "$HOME/subdir/file" ]
  [ "$(readlink "$HOME/subdir/file")" = "$DOTFILES_TOPIC_ROOT/sometopic/subdir/file.symlink" ]
}

@test "install_dotfiles(): symlinks a whole directory when the .symlink itself is a directory" {
  DOTFILES_TOPIC_ROOT="$BATS_TEST_TMPDIR/topics"
  mkdir -p "$DOTFILES_TOPIC_ROOT/sometopic/tool.symlink"
  echo inner > "$DOTFILES_TOPIC_ROOT/sometopic/tool.symlink/innerfile"

  install_dotfiles

  [ -L "$HOME/.tool" ]
  [ -f "$HOME/.tool/innerfile" ]
}

@test "install_dotfiles(): links a depth-4 .config/tool/file.symlink (the ghostty shape)" {
  DOTFILES_TOPIC_ROOT="$BATS_TEST_TMPDIR/topics"
  mkdir -p "$DOTFILES_TOPIC_ROOT/ghostty/.config/ghostty"
  echo content > "$DOTFILES_TOPIC_ROOT/ghostty/.config/ghostty/config.symlink"

  install_dotfiles

  [ "$(readlink "$HOME/.config/ghostty/config")" = "$DOTFILES_TOPIC_ROOT/ghostty/.config/ghostty/config.symlink" ]
}

# link_file() <src> <dst> - pre-existing destination branches
#######################################

@test "link_file(): skip_all leaves an existing destination untouched" {
  local src="$BATS_TEST_TMPDIR/src.symlink"
  local dst="$HOME/existing"
  echo source > "$src"
  echo original > "$dst"

  skip_all=true overwrite_all=false backup_all=false
  link_file "$src" "$dst"

  [ ! -L "$dst" ]
  [ "$(cat "$dst")" = original ]
}

@test "link_file(): overwrite_all replaces an existing destination with a symlink" {
  local src="$BATS_TEST_TMPDIR/src.symlink"
  local dst="$HOME/existing"
  echo source > "$src"
  echo original > "$dst"

  overwrite_all=true backup_all=false skip_all=false
  link_file "$src" "$dst"

  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "link_file(): backup_all moves the existing destination into BACKUP_DIR before linking" {
  local src="$BATS_TEST_TMPDIR/src.symlink"
  local dst="$HOME/existing"
  echo source > "$src"
  echo original > "$dst"

  backup_all=true overwrite_all=false skip_all=false
  link_file "$src" "$dst"

  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
  [ "$(cat "$BACKUP_DIR/existing")" = original ]
}

@test "install_dotfiles(): the existing-file prompt reads the answer from stdin, not the find loop" {
  DOTFILES_TOPIC_ROOT="$BATS_TEST_TMPDIR/topics"
  mkdir -p "$DOTFILES_TOPIC_ROOT/sometopic"
  echo content > "$DOTFILES_TOPIC_ROOT/sometopic/existing.symlink"
  echo content > "$DOTFILES_TOPIC_ROOT/sometopic/fresh.symlink"
  echo original > "$HOME/.existing"

  install_dotfiles <<< 'S'

  [ ! -L "$HOME/.existing" ]
  [ "$(cat "$HOME/.existing")" = original ]
  [ -L "$HOME/.fresh" ]
}

@test "link_file(): an existing symlink that already points at src is left alone without prompting" {
  local src="$BATS_TEST_TMPDIR/src.symlink"
  local dst="$HOME/existing"
  echo source > "$src"
  ln -s "$src" "$dst"

  overwrite_all=false backup_all=false skip_all=false
  run link_file "$src" "$dst" < /dev/null

  [ "$status" -eq 0 ]
  # Not [[ != ]]: bash 3.2 (macOS /bin/bash) doesn't trip errexit on a failed [[ ]]
  [ "${output#*File already exists}" = "$output" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "bootstrap: aborts before creating anything when HOME is unset, empty, relative or missing" {
  cd "$BATS_TEST_TMPDIR"
  local bad_home
  for bad_home in "" "~" "relative/dir" "$BATS_TEST_TMPDIR/does-not-exist"
  do
    run env HOME="$bad_home" bash "$BOOTSTRAP"
    [ "$status" -eq 1 ]
    [[ "$output" == *"HOME is not a valid absolute directory"* ]]
  done

  run env -u HOME bash "$BOOTSTRAP"
  [ "$status" -eq 1 ]
  [[ "$output" == *"HOME is not a valid absolute directory"* ]]

  [ -z "$(ls -A "$BATS_TEST_TMPDIR" | grep -v '^home$')" ]
}
