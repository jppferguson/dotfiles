# Run Claude Code billed to Console API credits instead of the subscription.
# The key lives in the login Keychain and is set only for this one process, so
# plain `claude` and scripted `claude -p` runs stay on the subscription.
# Pass any claude args through, e.g. `claude-api -c` to move a session onto credits.
claude-api() {
  local api_key
  if ! api_key=$(security find-generic-password -s anthropic-api-key -a "$USER" -w 2>/dev/null); then
    echo "No API key in the Keychain. Store one with:" >&2
    echo "  security add-generic-password -s anthropic-api-key -a \"\$USER\" -w" >&2
    return 1
  fi
  ANTHROPIC_API_KEY=$api_key command claude "$@"
}
