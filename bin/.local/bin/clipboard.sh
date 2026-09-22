#!/usr/bin/env bash
# clipboard.sh: pick an item from clipboard history

CHOICE=$(cliphist list | rofi -dmenu -i -p "Clipboard" -display-columns 2)
[ -z "$CHOICE" ] && exit 0
printf '%s' "$CHOICE" | cliphist decode | wl-copy