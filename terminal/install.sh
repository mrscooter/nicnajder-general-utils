#!/usr/bin/env bash
# Symlink the shared Ghostty/Zellij configs, themes and term-theme from this checkout; see --help.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd -P)
usage() {
    cat <<EOF
Usage: $0 [--check]

Symlink the shared terminal configs from this checkout:
  ~/.config/ghostty/config.ghostty, ~/.config/ghostty/themes/*
  ~/.config/zellij/config.kdl, ~/.config/zellij/{themes,layouts,plugins}/*
  ~/.local/bin/term-theme   switches Ghostty and Zellij themes together; without an argument it
                            lists the themes
On first install it activates the gold-dim theme. The chosen theme stays per machine, in untracked
~/.config/ghostty/local.ghostty and ~/.config/zellij/themes/active.kdl. Links whose target was
deleted or renamed in the repo are removed. Idempotent: re-run after a git pull that adds files.

Options:
  --check     report what differs from the repo, change nothing
  -h, --help  show this help

Anything in the way of a link is moved to backups/<date>_<time>/ in this checkout, never
overwritten. Exit status: 0 all done or all in place, 1 something failed or differs, 2 bad
arguments.
EOF
}
# shellcheck source=../lib/link.sh
source "$SRC/../lib/link.sh" "$@"
outside "$HOME/.config/ghostty/themes" "$HOME/.config/zellij/themes" "$HOME/.config/zellij/layouts" \
    "$HOME/.config/zellij/plugins" "$HOME/.local/bin"

link "$SRC/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
link "$SRC/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
for f in "$SRC"/ghostty/themes/*; do link "$f" "$HOME/.config/ghostty/themes/$(basename "$f")"; done
for d in themes layouts plugins; do
    for f in "$SRC/zellij/$d"/*; do link "$f" "$HOME/.config/zellij/$d/$(basename "$f")"; done
done
prune "$HOME/.config/ghostty/themes"
for d in themes layouts plugins; do prune "$HOME/.config/zellij/$d"; done
link "$SRC/term-theme" "$HOME/.local/bin/term-theme"

# The shared Zellij config needs a local "active" theme to exist.
if [[ ! -e $HOME/.config/zellij/themes/active.kdl ]]; then
    if (( CHECK )); then problem "$HOME/.config/zellij/themes/active.kdl: missing, run term-theme <name>"
    else
        # A failed term-theme can leave a half-written active.kdl that would pass as installed.
        out=$("$SRC/term-theme" gold-dim) || { rm -f "$HOME/.config/zellij/themes/active.kdl"; exit 1; }
        changed "$out"
    fi
fi

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "  warning: ~/.local/bin is not on PATH; add it to use term-theme" >&2 ;;
esac

finish
