# terminal

Matched Ghostty + Zellij color themes in a "medieval/renaissance meets modern computing" style (aged pigments, gold, ink; no rainbow), plus `term-theme` to switch both at once.

## Install on a machine

Requires a checkout at `~/Tools/nicnajder-general-utils` (any path works, the script resolves its own location), Ghostty, Zellij, and `~/.local/bin` on `PATH`.

```bash
~/Tools/nicnajder-general-utils/terminal/install.sh
term-theme manuscript
```

`install.sh` symlinks every file in `ghostty/themes/` into `~/.config/ghostty/themes/`, every file in `zellij/themes/` into `~/.config/zellij/themes/`, and `term-theme` into `~/.local/bin/`. It is idempotent: re-run it after a `git pull` that adds new themes. Edits to existing themes need no re-run, the symlinks already point into the checkout. Same-named files already in those dirs are replaced; other files there are left alone.

No config files need to exist beforehand: `term-theme` replaces the top-level `theme` line in `~/.config/ghostty/config.ghostty` and `~/.config/zellij/config.kdl`, or appends one if missing (creating the file if needed).

## Usage

```bash
term-theme                  # list themes, * marks the active one
term-theme next             # rotate within the active group (light or dark)
term-theme venetian-dark    # pick one by name; "dark" is an alias for gold-dim
```

Ghostty reloads via `SIGUSR2` (Ghostty >= 1.2), Zellij picks up `config.kdl` changes on its own. Both apply live.

## Themes

Ghostty file `royal-<name>`, Zellij theme `royal-<name>`.

| name | group | feel |
|---|---|---|
| `manuscript` | light | rich: vellum, iron-gall ink, vermilion, lapis, gold leaf |
| `venetian` | light | rich: ivory, burgundy, Medici green, ochre |
| `library` | light | muted: linen, sepia, brass, bottle green, oxblood |
| `stone` | light | muted, cool: limestone, slate, pewter, muted gold |
| `manuscript-dark` | dark | rich: oak-ink ground, vellum text, gold leaf, vermilion, lapis |
| `venetian-dark` | dark | rich: wine-black, ivory, crimson, Medici green, ochre |
| `library-dark` | dark | muted: dark leather, parchment text, brass, bottle green |
| `stone-dark` | dark | muted, cool: slate, pewter text, muted gold, slate blue |
| `gold-dim` | dark | Ghostty's built-in `Adventure` + Zellij `gold-dim` (black, gray text, muted gold) |

Body text contrast is 11-15:1 against the background and the normal ANSI colors (1-6) are around 4.5:1 or better, so `ls`, git and prompts stay readable. Zellij themes all share the same component layout: focused frame and active tab use the theme's main accent, unfocused frames recede toward the background.

## Adding a theme

Add `ghostty/themes/royal-<name>` and `zellij/themes/royal-<name>.kdl` (Zellij theme block named `royal-<name>`), append `<name>` to `LIGHT` or `DARK` in `term-theme`, then re-run `install.sh`.
