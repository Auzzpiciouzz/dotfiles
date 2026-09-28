# dotfiles

My Arch Linux + Hyprland setup: a Matugen-themed desktop where one wallpaper
change re-colours everything (Hyprland, Waybar, rofi, kitty, GTK, Qt, hyprlock,
swayosd, swaync), with btrfs snapshots before every package change.

Built for an HP Omen 16 (Intel Iris Xe + NVIDIA RTX 3050), but the install
script detects NVIDIA and skips hardware-specific parts on other machines.

## What's inside

| Folder | Contents |
|---|---|
| `hypr/` | Hyprland (Lua config), hypridle, hyprlock, hyprsunset |
| `waybar/` | Bar config, style, and module scripts |
| `matugen/` | Colour templates for every themed app |
| `kitty/`, `rofi/`, `qt6ct/`, `kanshi/`, `starship/`, `bash/` | App configs |
| `xdg-desktop-portal/` | Portal backend preferences |
| `bin/` | Scripts in `~/.local/bin` (wallpaper, theme mode, power menu, ...) |
| `packages/` | Package lists: official repos, NVIDIA, AUR |
| `system/` | Files copied into `/etc` (udev, modprobe, greetd, PAM, zram) |

Everything except `packages/` and `system/` is a GNU Stow package, symlinked
into `$HOME`. Files Matugen generates are git-ignored and recreated on install.

## Install

Prerequisite: a base Arch install with a user account, `sudo`, networking,
and btrfs subvolumes `@`, `@home`, `@log`, `@pkg`, `@.snapshots`.

```bash
git clone https://github.com/Auzzpiciouzz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh            # all phases
./install.sh stow desktop   # or only some: packages stow system services desktop
```

Existing files that would block a symlink are moved to `~/.dotfiles-backup/`.
Reboot when it finishes.

## Manual steps

**Snapper** (not automated because it touches the snapshot subvolume):

```bash
sudo umount /.snapshots && sudo rmdir /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots && sudo systemctl daemon-reload
sudo mount /.snapshots && sudo chmod 750 /.snapshots
sudo snapper -c root set-config TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
  TIMELINE_LIMIT_WEEKLY=0 TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0 \
  NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5 ALLOW_USERS="$USER" SYNC_ACL=yes
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
```

**Different hardware:** line 1 of `hypr/.config/hypr/hyprland.lua` sets
`AQ_DRM_DEVICES` to GPU symlinks created by `system/etc/udev/rules.d/99-gpu-symlinks.rules`,
which match this laptop's PCI addresses. On another machine, delete that line
or adapt the rule (`ls -l /dev/dri/by-path/`).

**Username:** `qt6ct.conf` contains an absolute path with `/home/auzz`.

**Not covered:** partitioning, bootloader, Secure Boot and UKI setup.

## Keybinds

| Keys | Action |
|---|---|
| `Super+Q` | Terminal (kitty) |
| `Super+Space` | App launcher |
| `Super+E` | File manager |
| `Super+B` | Firefox |
| `Super+V` | Clipboard history |
| `Super+W` | Pick wallpaper (re-themes everything) |
| `Super+Shift+S` / `Super+Print` | Screenshot area / full screen |
| `Super+F` | Toggle maximize |
| `Super+S` / `Super+Alt+S` | Show scratchpad / send window to it |
| `Super+L` | Lock |
| `Super+Escape` | Power menu |
| `Super+P` / `Super+I` | Display mode / settings menu |
| `Super+1..9` | Switch workspace |

Waybar theme toggle: left-click dark mode, right-click light mode.

## Updating

Configs are symlinks into this repo, so edits apply directly:

```bash
cd ~/dotfiles
git status          # see what changed
git add -A && git commit -m "Describe the change"
git push
```
