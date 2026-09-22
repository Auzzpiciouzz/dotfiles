#!/usr/bin/env bash
# updates.sh: print pending updates as Waybar JSON, or run the upgrade with "run"
CACHE="$HOME/.cache/waybar-updates.json"
AUR_HELPER=$(command -v paru || command -v yay)

if [[ "$1" == "run" ]]; then
  if [[ -n "$AUR_HELPER" ]]; then "$AUR_HELPER" -Syu; else sudo pacman -Syu; fi
  "$0" > /dev/null          # recount after upgrading
  pkill -RTMIN+8 waybar     # tell Waybar to refresh the module
  exit
fi

repo=$(checkupdates 2>/dev/null | wc -l)
aur=0
[[ -n "$AUR_HELPER" ]] && aur=$("$AUR_HELPER" -Qua 2>/dev/null | wc -l)
total=$((repo + aur))

if (( total > 0 )); then
  out=$(printf '{"text":"%s","class":"pending","tooltip":"%s repo, %s AUR updates"}' "$total" "$repo" "$aur")
else
  out='{"text":"","class":"updated","tooltip":"System up to date"}'
fi
echo "$out" | tee "$CACHE"
