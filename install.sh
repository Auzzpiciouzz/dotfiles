#!/usr/bin/env bash
# install.sh: set up this Hyprland rice on an Arch install
# Usage: ./install.sh [packages] [stow] [system] [services] [desktop]
#        No arguments runs every phase in order.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
HAS_NVIDIA=false
grep -qs 0x10de /sys/bus/pci/devices/*/vendor && HAS_NVIDIA=true   # 10de = NVIDIA's PCI vendor ID

info() { printf '\e[1;34m::\e[0m %s\n' "$*"; }
ok()   { printf '\e[1;32m✔\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m!\e[0m %s\n' "$*"; }

# Read a package list into the array PKGS, skipping comments and blank lines
read_pkgs() { mapfile -t PKGS < <(grep -v '^[[:space:]]*#' "$1" | tr -s ' \t' '\n' | grep -v '^$'); }

phase_packages() {
  info "Installing official packages"
  sudo pacman -S --needed base-devel git
  read_pkgs "$DOTS/packages/pacman.txt"; sudo pacman -S --needed "${PKGS[@]}"

  if $HAS_NVIDIA; then
    info "NVIDIA GPU detected: installing drivers"
    read_pkgs "$DOTS/packages/nvidia.txt"; sudo pacman -S --needed "${PKGS[@]}"
  fi

  if ! command -v paru >/dev/null; then
    info "Installing paru (AUR helper)"
    local tmp; tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si)
    rm -rf "$tmp"
  fi

  info "Installing AUR packages"
  read_pkgs "$DOTS/packages/aur.txt"; paru -S --needed "${PKGS[@]}"
  ok "Packages done"
}

# Move aside any real file that would block a stow symlink
backup_conflicts() {
  local pkg=$1 src rel tgt
  while IFS= read -r -d '' src; do
    rel=${src#"$DOTS/$pkg/"}
    tgt="$HOME/$rel"
    [[ -e "$tgt" || -L "$tgt" ]] || continue
    [[ "$(readlink -f "$tgt")" == "$(readlink -f "$src")" ]] && continue   # already linked
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$tgt" "$BACKUP/$rel"
  done < <(find "$DOTS/$pkg" \( -type f -o -type l \) -print0)
}

phase_stow() {
  info "Linking dotfiles with stow"
  mkdir -p "$HOME/.config" "$HOME/.local/bin"
  local dir pkg
  for dir in "$DOTS"/*/; do
    pkg=$(basename "$dir")
    [[ "$pkg" == packages || "$pkg" == system ]] && continue
    backup_conflicts "$pkg"
    if [[ "$pkg" == bin ]]; then
      stow -d "$DOTS" -t "$HOME" --no-folding -R "$pkg"
    else
      stow -d "$DOTS" -t "$HOME" -R "$pkg"
    fi
    ok "$pkg"
  done
  [[ -d "$BACKUP" ]] && warn "Existing files were moved to $BACKUP"
  return 0
}

phase_system() {
  info "Installing system config files"
  local src dst
  while IFS= read -r -d '' src; do
    dst="/${src#"$DOTS/system/"}"
    case "$dst" in
      */modprobe.d/nvidia.conf) $HAS_NVIDIA || continue ;;
      */99-gpu-symlinks.rules)
        [[ -e /sys/bus/pci/devices/0000:01:00.0 ]] || { warn "Skipping GPU udev rule (different PCI layout)"; continue; } ;;
    esac
    sudo install -Dm644 "$src" "$dst"
    ok "$dst"
  done < <(find "$DOTS/system" -type f -print0)

  local meta=/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
  if [[ -f "$meta" ]]; then
    sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/pixel_sakura.conf|' "$meta"
    ok "SDDM theme set to pixel_sakura"
  fi
  sudo udevadm control --reload
}

phase_services() {
  info "Enabling services"
  local svcs=(NetworkManager bluetooth cups power-profiles-daemon sddm)
  $HAS_NVIDIA && svcs+=(nvidia-suspend nvidia-resume)
  sudo systemctl enable "${svcs[@]}"

  if [[ -f /etc/snapper/configs/root ]]; then
    sudo systemctl enable snapper-timeline.timer snapper-cleanup.timer
  else
    warn "No snapper config yet: create it manually (see README), then enable its timers"
  fi
  ok "Services enabled"
}

phase_desktop() {
  info "Preparing theme and folders"
  mkdir -p ~/.config/{swaync,swayosd,gtk-3.0,gtk-4.0,qt6ct/colors,matugen/generated} \
           ~/.local/state/waybar ~/.cache ~/Pictures/{wallpapers,Screenshots}

  [[ -f ~/.cache/theme-mode ]] || echo dark > ~/.cache/theme-mode
  local mode; mode=$(cat ~/.cache/theme-mode)
  local gtk=adw-gtk3; [[ "$mode" == dark ]] && gtk=adw-gtk3-dark
  gsettings set org.gnome.desktop.interface gtk-theme "$gtk" || warn "gsettings failed (run again inside Hyprland)"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode" || true

  local wall
  wall=$(find ~/Pictures/wallpapers -maxdepth 1 -type f \
         \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | head -1)
  if [[ -n "$wall" ]]; then
    matugen image "$wall" -m "$mode" --source-color-index 0 \
      || warn "Matugen reported errors (hooks fail outside a Hyprland session; that's fine)"
  else
    matugen color hex "#4a6fa5" -m "$mode" \
      || warn "Matugen reported errors (hooks fail outside a Hyprland session; that's fine)"
    warn "No wallpapers yet: add some to ~/Pictures/wallpapers, then press Super+W"
  fi
  ok "Theme generated"
}

main() {
  [[ $EUID -eq 0 ]] && { echo "Run this as your normal user, not root."; exit 1; }
  local phases=("$@")
  (( ${#phases[@]} )) || phases=(packages stow system services desktop)
  local p
  for p in "${phases[@]}"; do
    declare -F "phase_$p" >/dev/null || { warn "Unknown phase: $p"; exit 1; }
    "phase_$p"
  done
  info "Done. Reboot to start the full session."
  warn "Manual steps: snapper config, and on different hardware check AQ_DRM_DEVICES in hyprland.lua"
}

main "$@"
