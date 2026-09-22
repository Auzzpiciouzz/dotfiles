#!/usr/bin/env bash
# nightlight.sh: toggle hyprsunset between warm (4500K) and normal
STATE="${XDG_RUNTIME_DIR:-/tmp}/nightlight-on"
if [[ -f "$STATE" ]]; then
  hyprctl hyprsunset identity && rm -f "$STATE"
  notify-send "Night light" "Off"
else
  hyprctl hyprsunset temperature 4500 && touch "$STATE"
  notify-send "Night light" "On (4500K)"
fi
