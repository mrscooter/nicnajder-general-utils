# Global Instructions

Instructions come from two files, both imported through `~/.claude/`:
- General rules for every machine: @~/.claude/GLOBAL-GENERAL-CLAUDE.md (symlink to `nicnajder-general-utils/claude/GLOBAL-GENERAL-CLAUDE.md`)
- Rules for this machine only: @~/.claude/LOCAL-CLAUDE.md (a local file, in no repo). Where they differ from the general rules, they win.

**Symlink integrity:** this file, the general rules and personal skills under `~/.claude/skills/` are symlinks into the `nicnajder-general-utils` checkout. A broken one makes the import or skill silently yield nothing. If the general rules seem missing or empty, or a referenced skill won't load, **STOP and loudly tell the user; do not silently proceed with missing instructions.**
