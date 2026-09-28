#!/usr/bin/env bash
# wallpaper-cycle.sh next|prev: step through ~/Pictures/wallpapers, then hand off to wallpaper.sh
DIR="$HOME/Pictures/wallpapers"
STATE="$HOME/.cache/wallpaper-current"
shopt -s nullglob nocaseglob

mapfile -t WALLS < <(printf '%s\n' "$DIR"/*.{jpg,jpeg,png,webp} | grep . | sort)
n=${#WALLS[@]}
(( n )) || { notify-send "No wallpapers in $DIR"; exit 1; }

# Find the current wallpaper's position (defaults to 0 if unknown)
cur=$(cat "$STATE" 2>/dev/null)
i=0
for idx in "${!WALLS[@]}"; do
    [[ "${WALLS[$idx]}" == "$cur" ]] && { i=$idx; break; }
done

case "$1" in
    prev) i=$(( (i - 1 + n) % n )) ;;
    *)    i=$(( (i + 1) % n )) ;;
esac

# flock -n: if a change is still running (Matugen takes ~1s), ignore this press
exec flock -n "$XDG_RUNTIME_DIR/wallpaper.lock" "$HOME/.local/bin/wallpaper.sh" "${WALLS[$i]}"
