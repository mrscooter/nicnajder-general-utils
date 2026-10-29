# Ničnajder General Utils

A personal, long-term collection of dev configs, snippets and small tools, shared across machines. Strictly hands-on tech, no theory write-ups. You are welcome to use it on your own machine.

An installer symlinks the configs from this checkout into place, so editing a file in the repo (or a `git pull`) changes it on the machine right away. Machine-specific settings live in untracked local files that the shared configs pull in, so local tweaks never dirty the repo.

## What's inside

| directory | what | how you get it |
|---|---|---|
| [`claude/`](claude/) | Claude Code: global rules (`~/.claude/CLAUDE.md`), a two-line status line, and the `ncn` plugin with skills (`/ncn:task-journal`, ...) | `./install.sh claude` |
| [`terminal/`](terminal/) | Ghostty + Zellij configs and keybindings, 9 matched color themes, the `term-theme` switcher, a vertical-tabs Zellij layout | `./install.sh terminal` |
| [`gdb/`](gdb/) | GDB snippets | source by hand, see [below](#use-the-gdb-snippet) |
| `lib/link.sh` | helpers shared by the component installers | - |

## Quick start

Requirements:

- bash, git
- `claude` component: the [Claude Code](https://claude.com/claude-code) CLI (`claude`) and `jq`
- `terminal` component: Ghostty >= 1.2, Zellij >= 0.45, `~/.local/bin` on `PATH`

```bash
git clone https://github.com/mrscooter/nicnajder-general-utils.git ~/Tools/nicnajder-general-utils
cd ~/Tools/nicnajder-general-utils
./install.sh --check      # dry run: lists what would change, changes nothing
./install.sh              # install everything
./install.sh terminal     # ...or only some components
```

Read this before installing:

- **The Claude rules are opinionated.** `~/.claude/CLAUDE.md` will load [`claude/GLOBAL-GENERAL-CLAUDE.md`](claude/GLOBAL-GENERAL-CLAUDE.md): the repo owner's rules for Claude (answer style, what it may do in git without asking, no attribution in commits, code style). Read it first. To use your own rules, fork the repo and edit that file.
- **Existing configs get replaced, never deleted.** Anything in the way of a link (your `~/.claude/CLAUDE.md`, Ghostty or Zellij config, ...) is moved to `backups/<date>_<time>/` in the checkout. `~/.claude/CLAUDE.md` is only replaced after a warning where you type `YES`.
- **Keep the checkout where it is.** Everything installed is a symlink into it. If you move it, re-run `./install.sh` from the new place.

## How-to

### Check what is installed

```bash
./install.sh --check
```

Prints `ok` per component, or every difference from the repo; exits 1 if anything differs. The `ncn` plugin runs the same check at every Claude Code session start and warns you when something is off.

### Update

```bash
git pull
./install.sh      # only needed when the pull added, removed or renamed files
```

Edits to existing files are live right away, the links already point at them. A re-run also removes links to files that were deleted or renamed in the repo.

### Add Claude rules for one machine only

`~/.claude/LOCAL-CLAUDE.md` is a plain untracked file, created by the installer and never touched again. Its rules are loaded after the general ones and win where they differ:

```bash
echo '- This machine has no GPU: never suggest CUDA builds.' >> ~/.claude/LOCAL-CLAUDE.md
```

### Change the shared Claude rules

Edit `claude/GLOBAL-GENERAL-CLAUDE.md` in the checkout and commit. It applies from the next Claude Code session; other machines get it with `git pull`.

### Use the Claude skills

Type the command in Claude Code, optionally followed by the task, e.g. `/ncn:task-journal migrate billing to the v2 API`. Claude also uses a skill on its own when your request matches its description.

| command | use it for |
|---|---|
| `/ncn:task-journal` | long, multi-session tasks (bug hunts, migrations, audits): keeps a journal on disk (brief, findings, status, progress log) that survives context compaction and new sessions |
| `/ncn:review-walkthrough` | going through code-review findings one at a time (accept / reject / defer / won't fix), then implementing what was agreed; pairs with `/code-review` |
| `/ncn:3designs` | a UI change as N variants you switch between live in the running web app; after you pick one, the rest is removed without a trace |
| `/ncn:step-by-step` | being walked through a how-to one step per message, Claude waits for you in between |
| `/ncn:nitrancina` | Claude speaks nitránčina, the Slovak dialect of Nitra |

Skills load from the checkout: edits to `claude/skills/*/SKILL.md` apply at the next session start or after `/reload-plugins`.

### Switch the terminal theme

```bash
term-theme                # list themes, * marks the active one
term-theme next           # next theme in the same group (light or dark)
term-theme venetian       # pick one by name; "dark" is short for gold-dim
zellij -l vtabs           # Zellij with the tab list in a left sidebar
```

Ghostty and Zellij switch together, live. The choice is per machine and stays out of the repo. Theme list, editing the configs and adding a theme: [`terminal/README.md`](terminal/README.md).

### Use the GDB snippet

`gdb/silence-noisy-signals.gdb` stops GDB from pausing on, and printing, the signals multithreaded C++ apps raise constantly (SIGPIPE, SIGUSR1/2, SIG32-34); the app still receives them. Load it in every GDB session:

```bash
echo "source $HOME/Tools/nicnajder-general-utils/gdb/silence-noisy-signals.gdb" >> ~/.gdbinit
```

Or once, inside GDB: `source <checkout>/gdb/silence-noisy-signals.gdb`.

### Install without prompts (containers, scripts)

```bash
./install.sh --yes claude
```

Answers `YES` to every confirmation. What gets replaced still goes to `backups/`.

### Undo: uninstall and restore backups

```bash
cd ~/Tools/nicnajder-general-utils
claude plugin uninstall ncn@nicnajder-general-utils
claude plugin marketplace remove nicnajder-general-utils
# Remove every link that points into this checkout.
find ~/.claude ~/.config/ghostty ~/.config/zellij ~/.local/bin -maxdepth 2 -type l -lname "$(pwd -P)/*" -delete
ls backups/                                          # one directory per install run that moved something
cp -a --remove-destination backups/<date>_<time>/. ~/
```

The oldest backup directory holds what was there before the first install. Keep `--remove-destination`: with a link still in place, plain `cp -a` writes through it into the repo file. The installer also set `statusLine` in `~/.claude/settings.json` without backing up the old value: remove it or set your own back. The untracked local files (`~/.claude/LOCAL-CLAUDE.md`, `~/.config/ghostty/local.ghostty`, `~/.config/zellij/themes/active.kdl`) stay until you delete them.

### Add a new component

Snippets that are only sourced or copied by hand just need a directory per tool (`gdb/`, `python/`, ...) and a line under [What's inside](#whats-inside). For something to install, add `<name>/install.sh` (executable) built on `lib/link.sh`:

```bash
#!/usr/bin/env bash
# Symlink the foo config from this checkout; see --help.
set -euo pipefail

SRC=$(cd "$(dirname "$0")" && pwd -P)
usage() { echo "Usage: $0 [--check] [--yes]"; }
# shellcheck source=../lib/link.sh
source "$SRC/../lib/link.sh" "$@"

outside "$HOME/.config/foo"                          # refuse to install through a link into the checkout
link "$SRC/foo.conf" "$HOME/.config/foo/foo.conf"    # anything in the way goes to backups/
prune "$HOME/.config/foo"                            # drop links to files deleted from the repo
finish
```

Then add `<name>` to `ALL` and to the help text in the top-level `install.sh`. `--check`, `--yes`, backups and the exit status come from `lib/link.sh`, whose header documents the helpers. Lint with `shellcheck` (`.shellcheckrc` makes it follow the `source` into `lib/link.sh`).

## Reference

### What `./install.sh claude` sets up

| on the machine | what it is |
|---|---|
| `~/.claude/CLAUDE.md` | link to `claude/TOP-LEVEL-CLAUDE.md`, which imports the two files below; local rules win |
| `~/.claude/GLOBAL-GENERAL-CLAUDE.md` | link to `claude/GLOBAL-GENERAL-CLAUDE.md`, the rules for every machine |
| `~/.claude/LOCAL-CLAUDE.md` | this machine's own rules: a plain file, created if missing, never touched after |
| `~/.claude/statusline-command.sh` | link to `claude/statusline-command.sh` |
| `statusLine` in `~/.claude/settings.json` | set to run the script above; no other key is touched |
| plugin `ncn@nicnajder-general-utils` | `claude/` itself, loaded in place from the checkout: the skills and the session-start check |

- `TOP-LEVEL-CLAUDE.md` is not named `CLAUDE.md` so that Claude doesn't load it as project instructions while working on this repo.
- The plugin is listed in `.claude-plugin/marketplace.json` at the repo root, defined in `claude/.claude-plugin/plugin.json`; its session-start check is `claude/hooks/check-install.sh`.
- `~/.claude/skills` must be a real directory or absent: the installer removes links in it that point into this checkout (skills come from the plugin), and a `~/.claude/skills` that is itself a link is removed (if it points to `claude/skills`) or moved to the backups.
- `keybindings.json` and the rest of `settings.json` stay per machine; `claude plugin` adds its own two entries for the plugin.

### The status line

Line 1: account, model, context use, effort, 5-hour and 7-day usage limits with reset times. Line 2: directory, git branch, lines added/removed. The icons need a [Nerd Font](https://www.nerdfonts.com/). For the usage limits it reads your Claude Code login token (`CLAUDE_CODE_OAUTH_TOKEN`, the macOS keychain, `~/.claude/.credentials.json` or `secret-tool`) and queries `api.anthropic.com/api/oauth/usage`, cached for 60 s in `/tmp/claude/`.

### Terminal

What gets linked where, the theme list and how the per-machine theme works: [`terminal/README.md`](terminal/README.md).
