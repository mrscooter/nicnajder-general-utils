#!/usr/bin/env bash
# Install the shared configs from this checkout by symlinking them into place; see --help.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd -P)
ALL=(claude terminal)

usage() {
    cat <<EOF
Usage: $0 [--check] [component...]

Install the shared configs from this checkout by symlinking them into place. Without a component,
installs all of them. Idempotent: re-run after a git pull that adds files (edits to existing files
need no re-run).

Components:
  claude      Claude Code: CLAUDE.md, GLOBAL-GENERAL-CLAUDE.md and LOCAL-CLAUDE.md, the status
              line, and the ncn plugin (skills, session-start check) in ~/.claude
  terminal    Ghostty and Zellij configs and themes in ~/.config, term-theme in ~/.local/bin

Options:
  --check     report what differs from the repo, change nothing; may come anywhere
  -h, --help  show this help; each component has its own: <component>/install.sh --help

Anything in the way of a link is moved to backups/<date>_<time>/ in this checkout (one directory
per run, under its path relative to ~), never overwritten.

Exit status: 0 all done or all in place, 1 something failed or differs, 2 bad arguments.
EOF
}

# No array for the components: an empty one trips set -u in bash < 4.4 (macOS).
check=
for a; do
    shift
    case $a in
        -h|--help) usage; exit 0 ;;
        --check) check=--check ;;
        *) set -- "$@" "$a" ;;
    esac
done
(( $# )) || set -- "${ALL[@]}"
# Validate every name before installing anything.
for c; do
    [[ " ${ALL[*]} " == *" $c "* ]] || { echo "unknown component: $c (have: ${ALL[*]}; see --help)" >&2; exit 2; }
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
