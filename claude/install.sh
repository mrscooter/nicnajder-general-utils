#!/usr/bin/env bash
# Set up the shared Claude Code config from this checkout in ~/.claude; see --help.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd -P)
usage() {
    cat <<EOF
Usage: $0 [--check] [--yes]

Set up the shared Claude Code config from this checkout in ~/.claude:
  CLAUDE.md                 link to claude/TOP-LEVEL-CLAUDE.md, which imports the two files below
                            (local rules win); an existing one is replaced only after a warning
                            and typing YES
  GLOBAL-GENERAL-CLAUDE.md  link to claude/GLOBAL-GENERAL-CLAUDE.md, the rules for every machine
  LOCAL-CLAUDE.md           this machine's own rules: a plain file, created if missing, never
                            touched after
  statusline-command.sh     link to claude/statusline-command.sh
  settings.json             statusLine set to run it; the only key set here, the rest stays as is
  plugin ncn@nicnajder-general-utils
                            claude/ itself, loaded in place: the skills (/ncn:3designs, ...) and a
                            session-start check that runs this script with --check and warns if
                            anything is off
Also removes links in ~/.claude/skills that point into this checkout (old skill links). When
~/.claude/skills itself is a link, it is removed if it points to claude/skills, else moved to the
backups. Idempotent: re-run after a git pull that adds files.
Needs the claude and jq commands. keybindings.json is never edited here; in settings.json only
statusLine is, and \`claude plugin\` adds its own two entries for the plugin.

Options:
  --check     report what differs from the repo, change nothing
  -y, --yes   replace an existing CLAUDE.md without asking; it still goes to the backups
  -h, --help  show this help

Anything in the way of a link is moved to backups/<date>_<time>/ in this checkout, never
overwritten. Exit status: 0 all done or all in place, 1 something failed or differs, 2 bad
arguments.
EOF
}
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

# statusline: point statusLine in settings.json at the linked script, leaving every other key alone.
statusline() {
    local file=$DEST/settings.json out
    local want='{"type": "command", "command": "bash ~/.claude/statusline-command.sh"}'
    if ! command -v jq >/dev/null; then
        problem "$file: setting statusLine needs the jq command"
        return 0
    fi
    [[ -s $file ]] && jq -e --argjson w "$want" '.statusLine == $w' "$file" >/dev/null 2>&1 && return 0
    if (( CHECK )); then
        problem "$file: statusLine does not run $DEST/statusline-command.sh"
        return 0
    fi
    # Written through, not replaced, so a settings.json that is itself a link stays one.
    if [[ -s $file ]]; then out=$(jq --argjson w "$want" '.statusLine = $w' "$file")
    else out=$(jq -n --argjson w "$want" '{statusLine: $w}'); fi ||
        { problem "$file: could not set statusLine (not valid JSON?)"; return 0; }
    printf '%s\n' "$out" > "$file"
    changed "$file: statusLine runs $DEST/statusline-command.sh"
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
statusline

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
