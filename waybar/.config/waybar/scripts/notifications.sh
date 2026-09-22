#!/usr/bin/env bash
export PATH="/usr/bin:/usr/local/bin:$PATH"
case "${1:-status}" in
  toggle) swaync-client -t -sw ;;
  clear)  swaync-client -C -sw; pkill -RTMIN+8 waybar 2>/dev/null ;;
  dnd)    swaync-client -d -sw; pkill -RTMIN+8 waybar 2>/dev/null ;;
  *)
    c=$(swaync-client -c 2>/dev/null || echo 0)
    d=$(swaync-client -D 2>/dev/null || echo false)
    if [ "$d" = "true" ]; then i="󰂛"; k="dnd"; elif [ "${c:-0}" -gt 0 ]; then i="󰂚"; k="pending"; else i="󰂚"; k="empty"; fi
    [ "${c:-0}" -gt 0 ] && t="$i $c" || t="$i"
    printf '{"text":"%s","class":"%s","tooltip":"%s notifications"}\n' "$t" "$k" "${c:-0}" ;;
esac
