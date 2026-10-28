#!/usr/bin/env bash
# Install the shared configs from this checkout by symlinking them into place. Idempotent: re-run
# after every pull.
#   ./install.sh                       all components
#   ./install.sh claude terminal       only these
#   ./install.sh --check [component]   report differences from the repo, change nothing;
#                                      exits 1 if anything is off
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
ALL=(claude terminal)

args=()
[[ ${1:-} == --check ]] && { args=(--check); shift; }
(( $# )) || set -- "${ALL[@]}"

status=0
for c in "$@"; do
    [[ " ${ALL[*]} " == *" $c "* ]] || { echo "unknown component: $c (have: ${ALL[*]})" >&2; exit 2; }
    echo "$c:"
    "$ROOT/$c/install.sh" "${args[@]}" || status=1
done
exit $status
