#!/usr/bin/env bash
#
# Print how many parallel agent workers this machine can take right now,
# from memory the OS could hand out without swapping. Used by queue-run
# before starting workers and before each replacement.
#
# Each worker is a full agent session plus its worktree's validation run
# (type-check, tests, sometimes a build), so the per-worker figure is the
# peak of both, not the agent alone. The coordinator and a deploy worker
# come out of the reserve.
#
# Usage: agent-capacity.sh [--per-worker-gb N] [--reserve-gb N] [--max N]
# Output: workers=<n> available_gb=<x> per_worker_gb=<y> pressure=<level>
# Always exits 0.

per_worker_gb=2.5
reserve_gb=3
max_workers=4

while [ $# -gt 0 ]; do
  # --max is compared with integer tests, so it takes whole numbers only.
  case "$1" in
    --per-worker-gb | --reserve-gb) pattern='^[0-9]+(\.[0-9]+)?$' ;;
    --max) pattern='^[0-9]+$' ;;
    *) echo "unknown option: $1" >&2; exit 0 ;;
  esac
  if [ $# -lt 2 ] || ! [[ $2 =~ $pattern ]]; then
    echo "$1 needs a number" >&2
    exit 0
  fi
  case "$1" in
    --per-worker-gb) per_worker_gb=$2 ;;
    --reserve-gb) reserve_gb=$2 ;;
    --max) max_workers=$2 ;;
  esac
  shift 2
done

pressure=normal
if [ "$(uname)" = "Darwin" ]; then
  # memory_pressure's free percentage counts reclaimable file cache and
  # compressible pages, which free + inactive from vm_stat leaves out (that
  # undercounted by half on a 16 GB machine).
  free_percent=$(memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ { sub(/%/, "", $2); print $2 }')
  available_bytes=$(($(sysctl -n hw.memsize) * ${free_percent:-0} / 100))
  case "$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)" in
    2) pressure=warn ;;
    4) pressure=critical ;;
  esac
  cpus=$(sysctl -n hw.ncpu)
else
  available_bytes=$(($(awk '/MemAvailable/ { print $2 }' /proc/meminfo) * 1024))
  cpus=$(nproc)
fi

workers=$(awk -v avail="$available_bytes" -v reserve="$reserve_gb" -v per="$per_worker_gb" \
  'BEGIN { n = int((avail / 1073741824 - reserve) / per); print (n < 0 ? 0 : n) }')

# Parallel validation runs are CPU bound too; past half the cores they
# slow each other down more than they gain.
cpu_cap=$((cpus / 2))
[ "$workers" -gt "$cpu_cap" ] && workers=$cpu_cap
[ "$workers" -gt "$max_workers" ] && workers=$max_workers

case "$pressure" in
  warn) workers=$((workers / 2)) ;;
  critical) workers=0 ;;
esac

available_gb=$(awk -v b="$available_bytes" 'BEGIN { printf "%.1f", b / 1073741824 }')
echo "workers=$workers available_gb=$available_gb per_worker_gb=$per_worker_gb pressure=$pressure"
