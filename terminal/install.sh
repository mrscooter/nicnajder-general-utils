#!/usr/bin/env bash
# Symlink the terminal themes and term-theme from this checkout into ~/.config and ~/.local/bin.
# Idempotent: re-run after pulling new themes. Existing files with the same name are replaced.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd)

link_dir() {
    local from=$1 to=$2 f
    mkdir -p "$to"
    for f in "$from"/*; do
        ln -sfn "$f" "$to/$(basename "$f")"
        echo "$to/$(basename "$f") -> $f"
    done
}

link_dir "$SRC/ghostty/themes" "$HOME/.config/ghostty/themes"
link_dir "$SRC/zellij/themes" "$HOME/.config/zellij/themes"
mkdir -p "$HOME/.local/bin"
ln -sfn "$SRC/term-theme" "$HOME/.local/bin/term-theme"
echo "$HOME/.local/bin/term-theme -> $SRC/term-theme"

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "warning: ~/.local/bin is not on PATH; add it to use term-theme" >&2 ;;
esac
