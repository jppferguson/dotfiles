# Rela guard, shared by the codex wrapper and the Claude Code hook. Sourced, not run.
#
# Runs personal-os's rela-guard (apps/rela/dist/guard.js), which refuses an agent in a checkout whose
# .context/policy.yaml denies it. See apps/rela/docs/materialiser.md -> "The guard" in personal-os.
# It stops accidents, not a determined bypass.

RELA_GUARD_JS="${RELA_GUARD_JS:-$HOME/Development/Personal/personal-os/apps/rela/dist/guard.js}"

# Prints the nearest .context/policy.yaml at or above $1 (a file or directory that may not exist yet).
rela_find_policy() {
    local dir=$1
    while [ ! -d "$dir" ] && [ "$dir" != / ]; do dir=$(dirname "$dir"); done
    while :; do
        if [ -f "$dir/.context/policy.yaml" ]; then
            printf '%s\n' "$dir/.context/policy.yaml"
            return 0
        fi
        [ "$dir" = / ] && return 1
        dir=$(dirname "$dir")
    done
}

# rela_guard <tool> <cwd> [path...]: returns 0 to proceed, or prints the reason and returns 1 to refuse.
rela_guard() {
    local tool=$1 cwd=$2
    shift 2
    local args=(--tool "$tool" --cwd "$cwd") target status=missing policy

    for target in "$@"; do args+=(--path "$target"); done

    if [ -f "$RELA_GUARD_JS" ]; then
        # Run node from the guard's own directory so asdf picks personal-os's pinned Node, not the checkout's.
        (cd -- "$(dirname -- "$RELA_GUARD_JS")" >/dev/null && "${RELA_GUARD_NODE:-node}" "$RELA_GUARD_JS" "${args[@]}")
        status=$?
        [ "$status" -eq 0 ] && return 0
        [ "$status" -eq 1 ] && return 1
    fi

    # The guard is not installed (every machine but the Mac mini) or failed to run. That only matters where a
    # policy applies, and there it fails closed. This fallback does not follow linked worktrees.
    for target in "$cwd" "$@"; do
        case $target in /*) ;; *) target="$cwd/$target" ;; esac
        if policy=$(rela_find_policy "$target"); then
            printf 'rela guard: %s is denied: %s applies here but %s did not run (%s), so failing closed\n' \
                "$tool" "$policy" "$RELA_GUARD_JS" "$([ "$status" = missing ] && echo "not installed" || echo "exit $status")" >&2
            return 1
        fi
    done
    return 0
}
