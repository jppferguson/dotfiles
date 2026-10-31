#!/usr/bin/env bash
# Start a Claude Code cloud session from a prompt file and print its ID and URL.
#
#   [CLOUD_MODEL=<model>] cloud-launch.sh <prompt-file>
#
# Run from the repo root. `claude --cloud` refuses --print, so it runs under a
# pseudo-terminal (script) with stdin closed: it creates the session, prints the
# URL and exits. Output on success, one line: SESSION <session_id> <url>
set -euo pipefail

prompt_file=${1:?usage: cloud-launch.sh <prompt-file>}
[[ -s $prompt_file ]] || { echo "ERROR prompt file is empty: $prompt_file" >&2; exit 2; }

# Cloud sessions clone from GitHub, so local-only work is invisible to them.
git fetch --quiet origin
branch=$(git rev-parse --abbrev-ref HEAD)
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [[ -z $upstream ]]; then
  echo "ERROR branch $branch has no upstream; push it first" >&2
  exit 3
fi
ahead=$(git rev-list --count "$upstream..HEAD")
if (( ahead > 0 )); then
  echo "ERROR $branch is $ahead commit(s) ahead of $upstream; push first" >&2
  exit 3
fi
if [[ -n $(git status --porcelain --untracked-files=no) ]]; then
  echo "WARN uncommitted changes are not visible to the cloud session" >&2
fi

log=$(mktemp -t cloud-launch)
trap 'rm -f "$log"' EXIT

model_args=()
[[ -n ${CLOUD_MODEL:-} ]] && model_args=(--model "$CLOUD_MODEL")
script -q "$log" claude ${model_args[@]+"${model_args[@]}"} --cloud "$(cat "$prompt_file")" < /dev/null > /dev/null 2>&1 &
pid=$!
url=""
for _ in $(seq 1 90); do
  url=$(grep -aoE 'https://claude\.ai/code/session_[A-Za-z0-9]+' "$log" | head -1 || true)
  [[ -n $url ]] && break
  kill -0 "$pid" 2>/dev/null || break
  sleep 2
done
kill "$pid" 2>/dev/null || true

if [[ -z $url ]]; then
  echo "ERROR no session URL within 180s; launcher output follows" >&2
  perl -pe 's/\e\[[0-9;?<>]*[ -\/]*[@-~]//g; s/\e\][^\a]*\a//g' "$log" | tr -s ' \r' | grep -av '^\s*$' | tail -20 >&2
  exit 4
fi

echo "SESSION ${url##*/} $url"
