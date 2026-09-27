#!/usr/bin/env bash
#
# Keep the Codex review profile's model current, using Codex's own models
# cache (refreshed by the CLI on every run), so no network call is needed.
#
# Two mechanical cases are applied automatically and announced on stderr:
#   - OpenAI has named an upgrade for the model (it is retiring)
#   - a newer generation of the same tier is listed (gpt-6-sol -> gpt-7-sol)
# Anything needing judgement (the tier no longer exists, the model is gone,
# hidden or labelled older/legacy) only warns: choosing a different tier
# changes rate-limit cost and review depth, and a silent tier swap is how
# review drifted onto a downgraded model once before.
#
# Always exits 0 so it never blocks a review.

profile="$HOME/.codex/review.config.toml"
cache="$HOME/.codex/models_cache.json"

command -v jq >/dev/null || exit 0
[ -f "$profile" ] && [ -f "$cache" ] || exit 0

model=$(sed -nE 's/^model[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$profile" | head -1)
[ -n "$model" ] || exit 0

# Prints "<new slug>\t<reason>" for one automatic step, or nothing.
next_model() {
  jq -r --arg slug "$1" '
    def parts: capture("^gpt-(?<v>[0-9.]+)-(?<tier>[a-z]+)$")?
      | {version: (.v | split(".") | map(tonumber)), tier};
    def usable: .visibility == "list" and .upgrade == null;
    (.models | map(select(.slug == $slug)) | first) as $m
    | ([$slug | parts] | first) as $p
    | if $m != null and $m.upgrade != null
         and any(.models[]; .slug == $m.upgrade.model and usable)
      then "\($m.upgrade.model)\tOpenAI retires \($slug) on \($m.upgrade.retirement_at[0:10]) and names this as its replacement"
      elif $p != null then
        [.models[] | select(usable) | {slug} + (.slug | parts // {})
          | select(.tier == $p.tier and .version > $p.version)]
        | max_by(.version)
        | if . == null then empty
          else "\(.slug)\tnewer generation of the same \($p.tier) tier" end
      else empty end
  ' "$cache"
}

original="$model"
# Bounded so a cycle in the upgrade data can never loop forever.
for _ in 1 2 3 4 5; do
  step=$(next_model "$model")
  [ -n "$step" ] || break
  model="${step%%$'\t'*}"
  echo "Codex review model: $model (${step#*$'\t'})" >&2
done

if [ "$model" != "$original" ]; then
  sed -i '' -E "s/^(model[[:space:]]*=[[:space:]]*\")[^\"]+(\")/\1$model\2/" "$profile"
  echo "UPDATED: Codex review model changed from $original to $model in $profile." >&2
fi

problem=$(jq -r --arg slug "$model" '
  (.models | map(select(.slug == $slug)) | first) as $m
  | if $m == null then "is no longer offered by Codex"
    elif $m.upgrade != null then "retires \($m.upgrade.retirement_at[0:10]); OpenAI suggests \($m.upgrade.model)"
    elif $m.visibility != "list" then "is hidden from the Codex model list"
    elif ($m.description | test("^(older|legacy)"; "i")) then "is described as: \($m.description | rtrimstr("."))"
    else empty end
' "$cache")

[ -n "$problem" ] || exit 0

current=$(jq -r '
  .models[]
  | select(.visibility == "list" and .upgrade == null)
  | select(.description | test("^(older|legacy)"; "i") | not)
  | "  \(.slug) - \(.description)"
' "$cache")

{
  echo "WARNING: Codex review model $model $problem."
  echo "This needs a judgement call (tier or cost change), so it was not updated automatically."
  echo "Current models:"
  echo "$current"
  echo "Update model in $profile."
} >&2
