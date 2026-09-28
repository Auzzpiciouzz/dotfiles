#!/usr/bin/env bash
# wallpaper.sh: pick a wallpaper from a thumbnail grid, set it, recolour the theme

DIR="$HOME/Pictures/wallpapers"
THUMBS="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$THUMBS"
shopt -s nullglob nocaseglob

THEME='
window { width: 70%; }
listview { columns: 4; lines: 3; spacing: 12px; }
element { orientation: vertical; padding: 8px; border-radius: 10px; }
element-icon { size: 200px; }
element-text { enabled: false; }
'

if [ -n "$1" ]; then
    WALL="$1"
else
    # Create a thumbnail for any wallpaper that doesn't have one yet
    for img in "$DIR"/*.{jpg,jpeg,png,webp}; do
        thumb="$THUMBS/$(basename "$img").png"
        [ -f "$thumb" ] || magick "$img" -thumbnail 400x225^ -gravity center -extent 400x225 "$thumb"
    done

    # Send each wallpaper to Rofi with its thumbnail attached as an icon
    CHOICE=$(for img in "$DIR"/*.{jpg,jpeg,png,webp}; do
        name=$(basename "$img")
        printf '%s\0icon\x1f%s\n' "$name" "$THUMBS/$name.png"
    done | rofi -dmenu -i -show-icons -p "Wallpaper" -theme-str "$THEME")

    [ -z "$CHOICE" ] && exit 0
    WALL="$DIR/$CHOICE"
fi

awww img "$WALL" --transition-type grow --transition-fps 60
echo "$WALL" > "$HOME/.cache/wallpaper-current"
MODE=$(cat "$HOME/.cache/theme-mode" 2>/dev/null || echo dark)
matugen image "$WALL" -m "$MODE" --source-color-index 0 > /tmp/matugen.log 2>&1 \
  || notify-send -u critical "Matugen failed" "$(tail -3 /tmp/matugen.log)"
