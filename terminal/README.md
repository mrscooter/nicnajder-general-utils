# terminal

Shared configs for the [Ghostty](https://ghostty.org) terminal and the [Zellij](https://zellij.dev) multiplexer, with matching color themes for both:

- **Configs**: mostly stock, with a few keybinding changes, all [listed below](#keybindings-that-differ-from-stock).
- **10 themes** (5 light, 5 dark) in a "medieval manuscript meets modern terminal" style: aged pigments, gold and ink, no rainbow. Each theme comes as a Ghostty + Zellij pair.
- **`term-theme`** switches Ghostty and Zellij together, live, in every open window. The chosen theme is per machine and never touches the repo.
- **`vtabs`**, a Zellij layout with the tab list in a left sidebar.

## Install

Requires Ghostty >= 1.2, Zellij >= 0.45 and `~/.local/bin` on `PATH`.

```bash
cd ~/Tools/nicnajder-general-utils    # wherever you cloned the repo
./install.sh --check terminal         # dry run: lists what would change
./install.sh terminal
term-theme manuscript                 # optional: the first install starts with gold-dim
```

Your existing Ghostty and Zellij configs are moved to `backups/<date>_<time>/` in the checkout, never deleted. Updating and undoing work as for the whole repo, see the [top-level README](../README.md#how-to).

## Switch the theme

```bash
term-theme                # list themes, * marks the active one
term-theme next           # next theme in the same group (light or dark)
term-theme venetian-dark  # pick one by name; "dark" is short for gold-dim
```

## Vertical tabs in Zellij

```bash
zellij -l vtabs           # start a session with the tab list in a left sidebar
```

- On first launch Zellij asks to grant the sidebar plugin its permissions: focus the sidebar and press `y`.
- `Alt s` makes the sidebar focusable, so you can resize it; press it again to switch back.
- The sidebar follows `term-theme`, live. The plugin can't read the Zellij theme, so it draws with the terminal's palette: slot 3 (accent) fills the active tab like Zellij's own tab bar, slot 8 (dim) colors the tab numbers. Every Ghostty theme here sets those two slots to its Zellij twin's colors.

The sidebar is the `v0.1.0` release of [cfal/zellij-vertical-tabs](https://github.com/cfal/zellij-vertical-tabs) (MIT), committed as `zellij/plugins/zellij-vertical-tabs.wasm`. To upgrade, replace that file with a newer release and commit.

## Keybindings that differ from stock

Ghostty:

| keys | does | stock Ghostty |
|---|---|---|
| `Ctrl+Shift+W` | close the focused split | close the whole tab |
| `Ctrl+Shift+K` | close the tab | unbound |
| `Ctrl+Shift+Arrows` | move to the split in that direction | Left/Right switch tabs |

Tabs still switch with `Ctrl+PageUp` / `Ctrl+PageDown` or `Alt+1`...`Alt+9`.

Zellij:

| keys | does | stock Zellij |
|---|---|---|
| `Ctrl+Q` | nothing (goes to the program in the pane); quit with `Ctrl+O`, then `Q` | quit Zellij |
| `Alt+S` | make the `vtabs` sidebar focusable | unbound |

Everything else is stock. Zellij's startup tips are also turned off.

## Per-machine settings

The shared configs never contain the theme. `term-theme` writes it to two untracked files:

- `~/.config/ghostty/local.ghostty`: the `theme = ...` line. `config.ghostty` includes this file last, so anything you put there wins. Use it for other per-machine Ghostty settings too:

  ```bash
  echo 'font-size = 13' >> ~/.config/ghostty/local.ghostty    # then reload (Ctrl+Shift+,) or open a new window
  ```

- `~/.config/zellij/themes/active.kdl`: a copy of the chosen Zellij theme, renamed to `active` (the shared `config.kdl` uses `theme "active"`). Its first line, `// term-theme: <name>`, records which theme it is.

The Zellij config has no local file: apart from the theme, its settings are the same on every machine.

## Edit the configs

Edit the files in the checkout (or through the links, they are the same files) and commit.

Watch out for Zellij's built-in configuration screen (`Ctrl+O`, then `C`): if it saves, it may replace the link `~/.config/zellij/config.kdl` with a regular file, and from then on your changes no longer reach the repo. `./install.sh --check terminal` reports it as "not a link". To fix it:

1. Copy `~/.config/zellij/config.kdl` over `zellij/config.kdl` in the checkout.
2. In the copy, set `theme "active"` back and delete the generated header comment.
3. Run `./install.sh terminal`: it moves the regular file to `backups/` and links the repo file again.

## Themes

| name | group | look |
|---|---|---|
| `manuscript` | light | rich: vellum, iron-gall ink, vermilion, lapis, gold leaf |
| `venetian` | light | rich: ivory, burgundy, Medici green, ochre |
| `library` | light | muted: linen, sepia, brass, bottle green, oxblood |
| `stone` | light | muted, cool: limestone, slate, pewter, muted gold |
| `gold-light` | light | muted, soft: warm-gray ground (dimmer than the others), dark gray text, muted gold; day pair of `gold-dim` |
| `manuscript-dark` | dark | rich: oak-ink ground, vellum text, gold leaf, vermilion, lapis |
| `venetian-dark` | dark | rich: wine-black, ivory, crimson, Medici green, ochre |
| `library-dark` | dark | muted: dark leather, parchment text, brass, bottle green |
| `stone-dark` | dark | muted, cool: slate, pewter text, muted gold, slate blue |
| `gold-dim` | dark | black, gray text, muted gold; the Ghostty side is the built-in `Adventure` with slots 3 and 8 retuned to gold-dim |

All are built for readability: body text has about 11-14:1 contrast against the background, and the normal ANSI colors 1-6 (used by `ls`, git, prompts) about 4.5:1 or better. In Zellij the focused pane frame and the active tab use the theme's main accent; unfocused frames fade toward the background.

### Add a theme

1. Add the Ghostty theme as `ghostty/themes/royal-<name>`. Set palette slot 3 to the Zellij theme's main accent and slot 8 to a dim gray: the `vtabs` sidebar draws with them.
2. Add the Zellij theme as `zellij/themes/royal-<name>.kdl`. Copy an existing one as a template: the theme block must be named `royal-<name>` and stay indented by 4 spaces, because `term-theme` finds and renames it by that line.
3. Append `<name>` to `LIGHT` or `DARK` at the top of `term-theme`.
4. Run `./install.sh terminal` to link the new files, then `term-theme <name>`.

## What gets installed where

| repo (`terminal/`) | linked as |
|---|---|
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` |
| `ghostty/themes/*` | `~/.config/ghostty/themes/*` |
| `zellij/config.kdl` | `~/.config/zellij/config.kdl` |
| `zellij/themes/*` | `~/.config/zellij/themes/*` |
| `zellij/layouts/*` | `~/.config/zellij/layouts/*` |
| `zellij/plugins/*` | `~/.config/zellij/plugins/*` |
| `term-theme` | `~/.local/bin/term-theme` |

Edits to these files are live right away. Re-run `./install.sh terminal` after a `git pull` that adds, removes or renames files: it links new ones and removes links to deleted ones.
