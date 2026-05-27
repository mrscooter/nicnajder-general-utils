# Ničnajder General Utils

A long-term harvest of reusable dev snippets, subtools, and small components.
Strictly hands-on tech, no theory write-ups.

## Organization

Utils are scoped per-tool: one top-level directory per tool/language/framework
(`claude/`, `gdb/`, and as they accrue `c++/`, `javascript/`, `python/`,
`django/`, etc.). Pick whatever granularity makes sense for the snippet.

## Contents

### `gdb/`
GDB config snippets, source with `source <file>` or from `~/.gdbinit`.
- `silence-noisy-signals.gdb` - stops GDB pausing/printing on the signals that
  multithreaded C++ apps raise constantly (SIGPIPE, SIGUSR1/2, SIG32-34);
  signals still pass through to the app.

### `claude/`
Claude Code configuration and skills.
- `GLOBAL-GENERAL-CLAUDE.md` - global instructions template (dev/learning modes,
  honest-feedback policy, code/formatting/debugging rules).
- `skills/task-journal/` - skill for keeping a persistent on-disk task journal
  across sessions: splits notes by role and mutability (brief, findings, status,
  progress log) so they survive context-window compaction and handoffs. Includes
  `SKILL.md` and file templates.
