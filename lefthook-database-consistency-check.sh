# shellcheck shell=bash
# Lefthook-compatible database_consistency gem wrapper.
# Runs bundle exec database_consistency and fails on any "fail" lines.
# Config: LEFTHOOK_DATABASE_CONSISTENCY_CONFIG (default: .database_consistency.todo.yml)
# NOTE: sourced by writeShellApplication - no shebang or set needed.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit

config="${LEFTHOOK_DATABASE_CONSISTENCY_CONFIG:-.database_consistency.todo.yml}"

config_args=()
if [ -f "$config" ]; then
    config_args=(-c "$config")
fi

output=$(bundle exec database_consistency "${config_args[@]}" 2>/dev/null | grep -v "^Loaded configurations:" || true)

if [ -n "$output" ]; then
    echo "$output"
    if echo "$output" | grep -q " fail"; then
        exit 1
    fi
fi
