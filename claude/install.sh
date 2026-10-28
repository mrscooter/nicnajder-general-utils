#!/usr/bin/env bash
# Symlink the shared Claude Code files from this checkout into ~/.claude. Idempotent: re-run after
# pulling new files. --check reports only. settings.json and keybindings.json stay per machine.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd)
source "$SRC/../lib/link.sh" "$@"

DEST=$HOME/.claude

# CLAUDE.md is the shared entry point: it imports the general rules and this machine's
# LOCAL-CLAUDE.md. An existing CLAUDE.md is only replaced after an explicit YES.
link "$SRC/CLAUDE.md" "$DEST/CLAUDE.md" confirm
link "$SRC/GLOBAL-GENERAL-CLAUDE.md" "$DEST/GLOBAL-GENERAL-CLAUDE.md"
# A missing import and an empty file look the same to Claude, so LOCAL-CLAUDE.md starts with a
# heading that CLAUDE.md treats as proof the file is there.
if [[ ! -e $DEST/LOCAL-CLAUDE.md ]]; then
    if (( CHECK )); then problem "$DEST/LOCAL-CLAUDE.md: missing"
    else echo "# Machine-specific rules" > "$DEST/LOCAL-CLAUDE.md"; changed "created $DEST/LOCAL-CLAUDE.md"; fi
fi

for d in "$SRC"/skills/*/; do link "${d%/}" "$DEST/skills/$(basename "$d")"; done
prune "$DEST/skills"

link "$SRC/statusline-command.sh" "$DEST/statusline-command.sh"

finish
