#!/usr/bin/env bash
# theme-mode.sh: switch Matugen between dark and light, keeping the current wallpaper
MODE="${1:-dark}"
[[ "$MODE" == dark || "$MODE" == light ]] || { echo "usage: $0 dark|light"; exit 1; }
echo "$MODE" > "$HOME/.cache/theme-mode"

WALL=$(awww query | head -1 | sed 's/.*image: //')
matugen image "$WALL" -m "$MODE" --source-color-index 0 > /tmp/matugen.log 2>&1 \
  || { notify-send -u critical "Matugen failed" "$(tail -3 /tmp/matugen.log)"; exit 1; }

if [[ "$MODE" == dark ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE"
