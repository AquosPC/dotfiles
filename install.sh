#!/usr/bin/env bash
# Restore this setup on a fresh Arch/CachyOS install:
#   git clone https://github.com/AquosPC/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail
cd "$(dirname "$(realpath "$0")")"

PACKAGES=(
  hyprland hyprpaper hyprlock hyprmocha backgrounds
  kitty waybar wofi starship fish
  gtk qt6ct nwg-look mimeapps vscodium dunst
)

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Repo has uncommitted changes; commit or stash them first." >&2
  exit 1
fi

# Packages: skip any not available in this system's repos (e.g. CachyOS-only ones on plain Arch)
sudo pacman -Sy --needed stow git
available=$(comm -12 <(sort pkglist.txt) <(pacman -Slq | sort -u))
missing=$(comm -23 <(sort pkglist.txt) <(pacman -Slq | sort -u))
sudo pacman -S --needed $available
[[ -n "$missing" ]] && echo "Not in repos, skipped: $missing"

if command -v paru >/dev/null; then
  paru -S --needed - < pkglist-aur.txt
else
  echo "paru not found; install AUR packages manually: $(tr '\n' ' ' < pkglist-aur.txt)"
fi

# Configs: --adopt pulls any default files the distro created into the repo,
# then git restore throws those away so the repo versions win.
stow --adopt -t "$HOME" "${PACKAGES[@]}"
git restore .

echo "Done. Log out and back in to start Hyprland with this config."
