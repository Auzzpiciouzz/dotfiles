#!/usr/bin/env bash
# screenshot.sh: full screen, or a selected area ("area")

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

case "$1" in
    area) GEOM=$(slurp) || exit 0; grim -g "$GEOM" "$FILE" ;;
    *)    grim "$FILE" ;;
esac

wl-copy < "$FILE"
notify-send -i "$FILE" "Screenshot saved" "$(basename "$FILE")"