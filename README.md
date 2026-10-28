# Ničnajder General Utils

A long-term harvest of reusable dev snippets, subtools, and small components.
Strictly hands-on tech, no theory write-ups.

## Organization

Utils are scoped per-tool: one top-level directory per tool/language/framework
(`claude/`, `gdb/`, and as they accrue `c++/`, `javascript/`, `python/`,
`django/`, etc.). Pick whatever granularity makes sense for the snippet.

## Install on a machine

Shared configs are symlinked from the checkout into place; machine-specific bits live in
untracked local files next to them, which the shared files pull in.

```bash
./install.sh                     # all components (claude, terminal)
./install.sh claude              # only some
./install.sh --check             # report what differs from the repo, change nothing; exit 1 if anything does
```

Idempotent: re-run after a `git pull` that adds files (edits to existing files need no re-run).
A regular file in the way is moved to `<name>.bak-<timestamp>`, never overwritten; an existing
`~/.claude/CLAUDE.md` is only replaced after typing `YES`. Links into the repo whose target was
deleted or renamed are removed. Each component's `install.sh` also runs on its own; the shared
helpers are in `lib/link.sh`.

## Contents

### `gdb/`
GDB config snippets, source with `source <file>` or from `~/.gdbinit`.
- `silence-noisy-signals.gdb` - stops GDB pausing/printing on the signals that
  multithreaded C++ apps raise constantly (SIGPIPE, SIGUSR1/2, SIG32-34);
  signals still pass through to the app.

### `terminal/`
Shared Ghostty + Zellij configs (keybindings), color themes and a per-machine theme switcher. See `terminal/README.md` for install (symlink) instructions.
- `ghostty/themes/`, `zellij/themes/` - matched light and dark "royal" themes (manuscript, venetian, library, stone) plus `gold-dim`.
- `term-theme` - switches Ghostty and Zellij together, live (`term-theme next`, `term-theme <name>`).
- `ghostty/config.ghostty`, `zellij/config.kdl` - shared configs; the theme lives in untracked per-machine files.
- `install.sh` - symlinks into `~/.config/{ghostty,zellij}/` and `~/.local/bin/`.

### `claude/`
Claude Code configuration and skills. `install.sh` links them into `~/.claude/`:

| repo | linked as |
|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` (asks for `YES` before replacing an existing one) |
| `GLOBAL-GENERAL-CLAUDE.md` | `~/.claude/GLOBAL-GENERAL-CLAUDE.md` |
| `skills/*` | `~/.claude/skills/*` |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` |

`settings.json` and `keybindings.json` stay per machine and are not touched.

- `CLAUDE.md` - shared entry point: imports `GLOBAL-GENERAL-CLAUDE.md` and the machine's own
  `~/.claude/LOCAL-CLAUDE.md` (created empty if missing, never touched after), whose rules win
  where they differ. Put machine-specific instructions and imports in `LOCAL-CLAUDE.md`.
- `GLOBAL-GENERAL-CLAUDE.md` - general rules for every machine (dev/learning modes,
  honest-feedback policy, code/formatting/debugging rules).
- `statusline-command.sh` - two-line status line (account, model, tokens, limits, effort; path, branch).
- `skills/3designs/` - skill for implementing a GUI/design ask as N runtime-switchable design
  variants behind a temporary dev-only switcher, then finalizing the chosen one without a trace.
- `skills/task-journal/` - skill for keeping a persistent on-disk task journal
  across sessions: splits notes by role and mutability (brief, findings, status,
  progress log) so they survive context-window compaction and handoffs. Includes
  `SKILL.md` and file templates.
- `skills/review-walkthrough/` - skill for triaging a code-review findings list one
  at a time (summary, severity, type, proposed fix), gathering an accept/reject/
  defer/won't-fix decision per finding, then implementing the agreed outcome. Pairs
  with `/code-review`.
