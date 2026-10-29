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
./install.sh --yes claude        # no prompts (e.g. in a container entrypoint); replaced files still go to backups/
./install.sh --help              # what it does; each component too: claude/install.sh --help
```

Idempotent: re-run after a `git pull` that adds files (edits to existing files need no re-run).
Anything in the way of a link is never overwritten: it is moved to `backups/<date>_<time>/` in this
checkout (gitignored, one directory per run) under its path relative to `~`, so
`cp -a backups/<date>_<time>/. ~/` restores it. An existing `~/.claude/CLAUDE.md` is only replaced
after a warning and typing `YES` (or with `--yes`). Links into the repo whose target was deleted
or renamed are removed. Each component's `install.sh` also runs on its own; the shared helpers are
in `lib/link.sh`.

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
Claude Code configuration and skills. `install.sh` (needs `claude` and `jq`) sets up a machine
like this:

| on the machine | what it is |
|---|---|
| `~/.claude/CLAUDE.md` | link to `TOP-LEVEL-CLAUDE.md`; an existing one is only replaced after a warning and `YES` |
| `~/.claude/GLOBAL-GENERAL-CLAUDE.md` | link to `GLOBAL-GENERAL-CLAUDE.md` |
| `~/.claude/LOCAL-CLAUDE.md` | this machine's own rules: a plain untracked file, created if missing, never touched after |
| `~/.claude/statusline-command.sh` | link to `statusline-command.sh` |
| `statusLine` in `~/.claude/settings.json` | set to run `~/.claude/statusline-command.sh` |
| plugin `ncn@nicnajder-general-utils` | `claude/` itself, loaded in place from the checkout: the skills and a session-start check |

`settings.json` and `keybindings.json` stay per machine; install sets only `statusLine` in
`settings.json`, and `claude plugin` adds its own two entries for the plugin. `~/.claude/skills`
must be a real directory (or absent): install removes a link to `claude/skills` there, and moves a
link anywhere else to the backups.

- `TOP-LEVEL-CLAUDE.md` - entry point, linked as `~/.claude/CLAUDE.md`: imports
  `GLOBAL-GENERAL-CLAUDE.md` and `~/.claude/LOCAL-CLAUDE.md`, whose rules win where they differ.
  It is not named `CLAUDE.md` so that Claude doesn't load it while working on this repo.
- `GLOBAL-GENERAL-CLAUDE.md` - general rules for every machine (dev/learning modes,
  honest-feedback policy, code/formatting/debugging rules).
- `statusline-command.sh` - two-line status line (account, model, tokens, limits, effort; path, branch).
- `.claude-plugin/plugin.json` - the `ncn` plugin; `.claude-plugin/marketplace.json` at the repo
  root lists it. Edits take effect at the next session start or after `/reload-plugins`.
- `hooks/check-install.sh` - runs `install.sh --check` at every session start; silent when all is
  in place, otherwise warns you and tells Claude what is missing.
- `skills/3designs/` - `/ncn:3designs`, for implementing a GUI/design ask as N runtime-switchable
  design variants behind a temporary dev-only switcher, then finalizing the chosen one without a
  trace.
- `skills/task-journal/` - `/ncn:task-journal`, for keeping a persistent on-disk task journal
  across sessions: splits notes by role and mutability (brief, findings, status,
  progress log) so they survive context-window compaction and handoffs. Includes
  `SKILL.md` and file templates.
- `skills/review-walkthrough/` - `/ncn:review-walkthrough`, for triaging a code-review findings
  list one at a time (summary, severity, type, proposed fix), gathering an accept/reject/
  defer/won't-fix decision per finding, then implementing the agreed outcome. Pairs
  with `/code-review`.
- `skills/step-by-step/` - `/ncn:step-by-step`, for leading the user through a how-to one
  actionable step per message (command chunk, expected result), waiting for "next" in between.
- `skills/nitrancina/` - `/ncn:nitrancina`, Claude speaks nitránčina, the Slovak dialect of Nitra.
