#!/usr/bin/env bash
# Wait for a cloud session to finish: its branch tip is a "cloud: report" commit.
#
#   watch-cloud-branch.sh <branch> [timeout-minutes, default 90] [previous-report-sha]
#
# After a rework request, pass the previous report's SHA so the old report
# doesn't count as finished. Exit 0 finished (prints DONE <branch> <sha>),
# 2 branch present but no new report by the deadline, 3 no branch at all.
# Run it in the background; the harness notifies on exit.
set -uo pipefail

branch=${1:?usage: watch-cloud-branch.sh <branch> [timeout-minutes] [previous-report-sha]}
deadline=$((SECONDS + ${2:-90} * 60))
previous=${3:-}
seen=0
while (( SECONDS < deadline )); do
  if [[ -n $(git ls-remote --heads origin "$branch") ]]; then
    seen=1
    if git fetch --quiet origin "+refs/heads/$branch:refs/remotes/origin/$branch"; then
      tip=$(git rev-parse "origin/$branch")
      if [[ $(git log -1 --format=%s "$tip") == "cloud: report" && ( -z $previous || $tip != "$previous"* ) ]]; then
        echo "DONE $branch $tip"
        exit 0
      fi
    fi
  fi
  sleep 30
done
if (( seen )); then echo "TIMEOUT $branch has no new cloud: report yet"; exit 2; fi
echo "MISSING $branch was never pushed"
exit 3
