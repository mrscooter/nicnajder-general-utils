#!/usr/bin/env bash
# Set up the shared Claude Code config from this checkout: link the instruction files and the status
# line into ~/.claude and install the ncn plugin (skills, session-start check) from it. Idempotent:
# re-run after pulling new files. --check reports only. settings.json and keybindings.json stay per
# machine; only `claude plugin` adds its own entries for the plugin.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd -P)
# shellcheck source=../lib/link.sh
source "$SRC/../lib/link.sh" "$@"

DEST=$HOME/.claude
PLUGIN=ncn@nicnajder-general-utils
outside "$DEST"

# plugin: make sure the ncn plugin is installed, enabled and loaded in place from this checkout.
plugin() {
    local state out
    if ! command -v claude >/dev/null || ! command -v jq >/dev/null; then
        problem "plugin $PLUGIN: needs the claude and jq commands"
        return 0
    fi
    state=$(claude plugin list --json |
        jq -r --arg id "$PLUGIN" '.[] | select(.id == $id) | "\(.enabled) \(.readFromFolder)"') ||
        { problem "plugin $PLUGIN: claude plugin list failed"; return 0; }
    [[ $state == "true "* && ${state#true } -ef $SRC ]] && return 0
    if (( CHECK )); then
        case $state in
            "") problem "plugin $PLUGIN: not installed" ;;
            "false "*) problem "plugin $PLUGIN: disabled" ;;
            *) problem "plugin $PLUGIN: loads from ${state#* }, expected $SRC" ;;
        esac
        return 0
    fi
    # Adding the marketplace again repoints it at this checkout; install also re-enables.
    out=$(claude plugin marketplace add "$REPO" 2>&1 && claude plugin install "$PLUGIN" 2>&1) ||
        { problem "plugin $PLUGIN: install failed: $out"; return 0; }
    changed "plugin $PLUGIN: installed, loads from $SRC"
}

# ~/.claude/CLAUDE.md imports the general rules and this machine's LOCAL-CLAUDE.md. An existing one
# is only replaced after an explicit YES.
link "$SRC/TOP-LEVEL-CLAUDE.md" "$DEST/CLAUDE.md" confirm
link "$SRC/GLOBAL-GENERAL-CLAUDE.md" "$DEST/GLOBAL-GENERAL-CLAUDE.md"
# LOCAL-CLAUDE.md is this machine's own file, not a link: created once, never touched again.
if [[ ! -e $DEST/LOCAL-CLAUDE.md ]]; then
    if (( CHECK )); then problem "$DEST/LOCAL-CLAUDE.md: missing"
    else echo "# Machine-specific rules" > "$DEST/LOCAL-CLAUDE.md"; changed "created $DEST/LOCAL-CLAUDE.md"; fi
fi
link "$SRC/statusline-command.sh" "$DEST/statusline-command.sh"

# Inside the plugin's own session-start hook (CLAUDE_PLUGIN_ROOT is set) the plugin evidently
# loads, so skip the slow CLI query there.
[[ -n ${CLAUDE_PLUGIN_ROOT:-} ]] || plugin
# Skill links from before the plugin would load every skill twice. ~/.claude/skills itself must not
# be a link either: one to claude/skills does the same, and anything else should be a real directory.
if [[ -L $DEST/skills ]]; then
    if (( CHECK )); then problem "$DEST/skills: links to $(readlink "$DEST/skills"), expected a real directory"
    elif [[ $DEST/skills -ef $SRC/skills ]]; then
        rm "$DEST/skills"; changed "removed $DEST/skills (a link to claude/skills; skills come from the ncn plugin now)"
    else
        target=$(readlink "$DEST/skills")
        backup "$DEST/skills"
        changed "the skills in $target no longer load; copy the ones you want into $DEST/skills"
    fi
fi
prune "$DEST/skills" "skills come from the ncn plugin now"

finish
