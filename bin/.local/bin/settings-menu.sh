#!/usr/bin/env bash
# settings-menu.sh: a Rofi control centre

CHOICE=$(printf "%s\n" \
  "󰍹  Display mode" \
  "󰹑  Display layout" \
  "󰸉  Wallpaper" \
  "󰕾  Sound" \
  "󰖩  Wi-Fi" \
  "󰂯  Bluetooth" \
  "󰏘  Appearance" \
  "󰾅  Power profile" \
  "󰍛  System monitor" \
  "  Hyprland config" \
  | rofi -dmenu -i -p "Settings")

case "$CHOICE" in
  *"Display mode"*)    ~/.local/bin/display-mode.sh ;;
  *"Display layout"*)  nwg-displays ;;
  *Wallpaper*)         ~/.local/bin/wallpaper.sh ;;
  *Sound*)             pavucontrol ;;
  *Wi-Fi*)             kitty -e nmtui ;;
  *Bluetooth*)         blueman-manager ;;
  *Appearance*)        nwg-look ;;
  *"Power profile"*)
      P=$(printf "performance\nbalanced\npower-saver\n" | rofi -dmenu -i -p "Power profile")
      [ -n "$P" ] && powerprofilesctl set "$P" ;;
  *"System monitor"*)  kitty -e btop ;;
  *"Hyprland config"*) code ~/.config/hypr/hyprland.lua ;;
esac