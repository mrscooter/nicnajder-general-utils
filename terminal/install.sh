#!/usr/bin/env bash
# Symlink the shared Ghostty/Zellij configs, themes and term-theme from this checkout into
# ~/.config and ~/.local/bin. Idempotent: re-run after pulling new files. --check reports only.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd)
source "$SRC/../lib/link.sh" "$@"

link "$SRC/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
link "$SRC/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
for f in "$SRC"/ghostty/themes/*; do link "$f" "$HOME/.config/ghostty/themes/$(basename "$f")"; done
for f in "$SRC"/zellij/themes/*; do link "$f" "$HOME/.config/zellij/themes/$(basename "$f")"; done
prune "$HOME/.config/ghostty/themes"
prune "$HOME/.config/zellij/themes"
link "$SRC/term-theme" "$HOME/.local/bin/term-theme"

# The shared Zellij config needs a local "active" theme to exist.
if [[ ! -e $HOME/.config/zellij/themes/active.kdl ]]; then
    if (( CHECK )); then problem "$HOME/.config/zellij/themes/active.kdl: missing, run term-theme <name>"
    else changed "$("$SRC/term-theme" gold-dim)"; fi
fi

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "  warning: ~/.local/bin is not on PATH; add it to use term-theme" >&2 ;;
esac

finish
