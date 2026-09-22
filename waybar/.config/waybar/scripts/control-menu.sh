#!/usr/bin/env bash
export PATH="/usr/bin:/usr/local/bin:$PATH"
# Compact control center via rofi — reuses your existing scripts
SC="$HOME/.config/waybar/scripts"

prof=$(powerprofilesctl get 2>/dev/null || echo "?")
dnd=$(swaync-client -D 2>/dev/null || echo false)
dnd_label="Do Not Disturb: OFF"; [ "$dnd" = "true" ] && dnd_label="Do Not Disturb: ON"

options="  Power profile  (now: $prof)
󰂚  $dnd_label
󰖩  Wi-Fi
󰂯  Bluetooth
󰄄  Screenshot
󰸉  Wallpaper
  Lock
󰐥  Power menu"

sel=$(printf '%s\n' "$options" | rofi -dmenu -i -p "Control" -theme-str 'window {width: 22em;} listview {lines: 8;}')

case "$sel" in
  *"Power profile"*) kitty --class control_power --hold -e "$SC/power-menu.sh" ;;
  *"Do Not Disturb"*) swaync-client -d -sw ;;
  *"Wi-Fi"*) kitty -e nmtui ;;
  *"Bluetooth"*) command -v blueman-manager >/dev/null && blueman-manager || kitty -e bluetoothctl ;;
  *"Screenshot"*) grim -g "$(slurp)" - | satty -f - ;;
  *"Wallpaper"*) command -v waypaper >/dev/null && waypaper || notify-send "Wallpaper" "Use Super+W" ;;
  *"Lock"*) command -v hyprlock >/dev/null && hyprlock ;;
  *"Power menu"*) ~/.local/bin/power-menu.sh ;;
esac
