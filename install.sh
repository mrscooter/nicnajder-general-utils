#!/usr/bin/env bash
# Install the shared configs from this checkout by symlinking them into place. Idempotent: re-run
# after every pull.
#   ./install.sh                       all components
#   ./install.sh claude terminal       only these
#   ./install.sh --check [component]   report differences from the repo, change nothing;
#                                      exits 1 if anything is off
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd -P)
ALL=(claude terminal)

# --check may come anywhere. No array for the rest: an empty one trips set -u in bash < 4.4 (macOS).
check=
for a; do
    shift
    if [[ $a == --check ]]; then check=--check; else set -- "$@" "$a"; fi
done
(( $# )) || set -- "${ALL[@]}"
# Validate every name before installing anything.
for c; do
    [[ " ${ALL[*]} " == *" $c "* ]] || { echo "unknown component: $c (have: ${ALL[*]})" >&2; exit 2; }
done

# One backups/<stamp>/ directory for the whole run.
INSTALL_STAMP=$(date +%Y-%m-%d_%H-%M-%S)
export INSTALL_STAMP
status=0
for c; do
    echo "$c:"
    "$ROOT/$c/install.sh" $check || status=1
done
exit $status
