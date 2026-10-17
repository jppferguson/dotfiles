# Running these as root leaves root-owned files in /opt/homebrew (or asdf's
# installs), which later breaks `brew cleanup` and upgrades. `function` syntax
# avoids prezto's `sudo` alias expanding inside the definition.
function sudo {
  case "$1" in
    brew|gem|bundle|bundler|pod)
      echo "sudo: refusing to run '$1' as root; run it without sudo" >&2
      return 1
      ;;
  esac
  command sudo "$@"
}
