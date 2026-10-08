# dotfiles

Personal Linux desktop config for **CachyOS (Arch) + Hyprland**, managed with **GNU Stow**.
Forked from [typecraft-dev/dotfiles](https://github.com/typecraft-dev/dotfiles) (remote `upstream`); this fork is `origin` → `github.com/AquosPC/dotfiles`.

This file is the single source of context for humans and AI coding agents. `AGENTS.md` and `CLAUDE.md` are symlinks to it.

## Restore on a new machine

```sh
git clone https://github.com/AquosPC/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Then log out and back in. `install.sh`:
1. Refuses to run if the repo has uncommitted changes (step 3 relies on `git restore`).
2. Installs `pkglist.txt` with pacman, skipping anything not in the current repos (CachyOS-only packages on plain Arch), then `pkglist-aur.txt` with `paru` if it is installed.
3. Runs `stow --adopt` for every package in its `PACKAGES` array, then `git restore .`. That replaces any default files the distro created with the repo versions.

## How Stow works here

Each top-level directory is a **stow package** that mirrors `$HOME`:

```
kitty/.config/kitty/kitty.conf   →   ~/.config/kitty/kitty.conf (symlink)
```

`stow -t ~ kitty` creates the symlinks. The real files live in this repo. **Editing `~/.config/...` edits the repo**, so changes only need a commit.

Stow links a whole directory when the target doesn't exist yet (e.g. `~/.config/qt6ct`, `~/.config/wofi`, `~/.config/backgrounds`). When the target directory already exists, it links individual files (e.g. `~/.config/hypr/*`). Either way, new files created inside a directory-linked config also land in the repo.

## Packages

### Active (stowed by `install.sh`)

| Package | Target | Notes |
|---|---|---|
| `hyprland` | `~/.config/hypr/hyprland.lua`, `hypridle.conf` | Main compositor config, written in **Hyprland's Lua format** (`hl.*` API), not `hyprland.conf`. |
| `hyprpaper` | `~/.config/hypr/hyprpaper.conf` | Wallpaper; points at `~/.config/backgrounds/kitty.jpg`. |
| `hyprlock` | `~/.config/hypr/hyprlock.conf` | Lock screen (`SUPER+L`, and after 5 min idle via hypridle). |
| `hyprmocha` | `~/.config/hypr/mocha.conf` | Catppuccin Mocha colour variables. |
| `backgrounds` | `~/.config/backgrounds/` | Wallpaper images. |
| `kitty` | `~/.config/kitty/` | Terminal. Font: CaskaydiaCove Nerd Font Mono 14; theme in `current-theme.conf`. |
| `waybar` | `~/.config/waybar/` | Bar: workspaces · window title · claudebar, network, audio, battery, clock. |
| `wofi` | `~/.config/wofi/` | App launcher (`SUPER+Space`). |
| `starship` | `~/.config/starship.toml` | Shell prompt. |
| `fish` | `~/.config/fish/config.fish` | Login shell. Sources CachyOS's fish config, inits starship, adds `~/.local/bin` to PATH. |
| `gtk` | `~/.config/gtk-{3,4}.0/settings.ini` | GTK theme settings (set via nwg-look). |
| `nwg-look` | `~/.config/nwg-look/config` | GTK theme tool settings. |
| `qt6ct` | `~/.config/qt6ct/` | Qt theme settings. |
| `mimeapps` | `~/.config/mimeapps.list` | Default applications. |
| `vscodium` | `~/.config/VSCodium/User/settings.json` | Editor settings only (no extensions or state). |
| `dunst` | `~/.config/dunst/dunstrc` | Notifications. Catppuccin Mocha, top-right, matches Hyprland gaps/border/rounding. Started on demand by D-Bus, not autostart. |

### Inactive (inherited from upstream, not stowed)

`alacritty`, `ghostty`, `herdr`, `i3`, `nvim`, `picom`, `polybar`, `rofi`, `screenlayout`, `tmux`, `xresources`, `zshrc`.
These are typecraft's configs, mostly for an X11/i3 setup. Leave them alone unless asked. To start using one, add it to `PACKAGES` in `install.sh` and stow it.

## Desktop at a glance

- **Theme:** Catppuccin Mocha everywhere.
- **Programs** (variables at the top of `hyprland.lua`): terminal `kitty`, files `dolphin`, launcher `wofi`, browser `helium-browser`, editor `codium`.
- **Autostart:** `waybar & hyprpaper & hypridle`.
- **Monitors:** a single catch-all rule (`preferred`, `auto`, `auto`).
- **Key binds** (`SUPER` = mod):

| Keys | Action |
|---|---|
| `SUPER+Return` | Terminal |
| `SUPER+Space` | App launcher |
| `SUPER+B` / `E` / `C` | Browser / file manager / editor |
| `SUPER+A` | `kitty claude` (Claude Code) |
| `SUPER+Q` | Close window |
| `SUPER+F` | Fullscreen |
| `SUPER+V` / `P` / `J` | Toggle float / pseudo-tile / split direction |
| `SUPER+L` | Lock (hyprlock) |
| `SUPER+M` | Exit Hyprland |
| `SUPER+Arrows` | Move focus |
| `SUPER+1..0` / `SUPER+SHIFT+1..0` | Go to / move window to workspace |
| `SUPER+S` / `SUPER+SHIFT+S` | Toggle / send to scratchpad (`special:magic`) |
| `Print` / `SUPER+Print` | Region screenshot to clipboard / to file (hyprshot) |
| Media keys | Volume (wpctl), brightness (brightnessctl), playback (playerctl) |

## Common tasks

**Change a config that's already tracked:** edit it (in the repo or through the symlink), reload, then commit.

| Config | Reload |
|---|---|
| Hyprland | Auto-reloads on save, or `hyprctl reload` |
| Waybar | `pkill waybar; waybar & disown` |
| hyprpaper | `pkill hyprpaper; hyprpaper & disown` |
| kitty | `ctrl+shift+F5` inside kitty |
| fish | `exec fish` |
| dunst | `pkill dunst` (D-Bus restarts it on the next notification); test with `notify-send hi` |

**Track a new config** (e.g. `~/.config/btop/btop.conf`):
```sh
cd ~/dotfiles
mkdir -p btop/.config/btop && touch btop/.config/btop/btop.conf
stow --adopt -t ~ btop      # moves the live file into the repo, symlinks it back
git diff                    # --adopt overwrites repo files with live ones; check it
```
Then add `btop` to `PACKAGES` in `install.sh`, add a row to the table above, and commit.

**Update the package lists** after installing or removing software:
```sh
pacman -Qqen > ~/dotfiles/pkglist.txt       # official repos
pacman -Qqem > ~/dotfiles/pkglist-aur.txt   # AUR / foreign
```

**Pull upstream changes from typecraft:** `git fetch upstream && git merge upstream/master`. Expect conflicts in files changed here (`hyprland/`, `hyprpaper/`, `kitty/`, `waybar/`). This fork deleted upstream's `hyprland.conf` on purpose.

**Check before stowing:** `stow -n -v -t ~ <pkg>` does a dry run and reports conflicts without changing anything.

## Rules for AI agents and contributors

- **Edit files in this repo, never by replacing symlinks.** Writing a new file over `~/.config/x` (e.g. with `mv` or editors that do atomic replace) breaks the link and the change won't be tracked. Check with `ls -l` if unsure.
- **Keep three things in sync** when adding or removing a package: the directory, the `PACKAGES` array in `install.sh`, and the tables in this README.
- **Never commit secrets.** The repo is public. Untracked on purpose: `~/.config/VSCodium/User/chatLanguageModels.json` (may hold API keys), `~/.config/fish/fish_variables` (machine-specific), anything under `~/.ssh`, browser profiles, `gh` auth.
- **Hyprland config is Lua.** Use the `hl.*` API (`hl.bind`, `hl.exec_cmd`, `hl.dsp.*`, `hl.monitor`) that `hyprland.lua` already uses. Don't add a `hyprland.conf`.
- **Don't modify inactive packages** unless asked; they're kept for reference and for upstream merges.
- **Test before committing:** dry-run stow for structure changes, `bash -n install.sh` for script changes, reload the program for config changes.
- `stow --adopt` **overwrites the repo copy** with whatever is live. Run it only on a clean tree and review `git diff` afterwards.

## Known issues

- `pkglist.txt` includes CachyOS-specific packages (kernel, `cachyos-*`). On plain Arch, `install.sh` skips and lists them.
- `pkglist-aur.txt` contains `claudebar`, which waybar's `custom/claudebar` module needs. Without it that module stays empty.
