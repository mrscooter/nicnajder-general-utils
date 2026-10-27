#!/usr/bin/env bash
# Symlink the shared Ghostty/Zellij configs, themes and term-theme from this checkout into
# ~/.config and ~/.local/bin. Idempotent: re-run after pulling new files.
# A regular file in the way is moved to <name>.bak-<timestamp> first, never overwritten.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%Y%m%d-%H%M%S)

link() {
    local from=$1 to=$2
    mkdir -p "$(dirname "$to")"
    if [[ -e $to && ! -L $to ]]; then
        mv "$to" "$to.bak-$STAMP"
        echo "backed up $to -> $to.bak-$STAMP"
    fi
    ln -sfn "$from" "$to"
    echo "$to -> $from"
}

link "$SRC/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
link "$SRC/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
for f in "$SRC"/ghostty/themes/*; do link "$f" "$HOME/.config/ghostty/themes/$(basename "$f")"; done
for f in "$SRC"/zellij/themes/*; do link "$f" "$HOME/.config/zellij/themes/$(basename "$f")"; done
link "$SRC/term-theme" "$HOME/.local/bin/term-theme"

# The shared Zellij config needs a local "active" theme to exist.
[[ -e $HOME/.config/zellij/themes/active.kdl ]] || "$SRC/term-theme" gold-dim

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "warning: ~/.local/bin is not on PATH; add it to use term-theme" >&2 ;;
esac
