#!/usr/bin/env bash
export PATH="/usr/bin:/usr/local/bin:$PATH"
set -uo pipefail
S="${XDG_RUNTIME_DIR:-/tmp}/waybar-net-simple"
case "${1:-h}" in --vertical|vertical) M=v;; up) M=up;; down) M=down;; unit) M=unit;; *) M=h;; esac
I=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
[ -z "${I:-}" ] && for n in /sys/class/net/*; do b=${n##*/}; [ "$b" = lo ] && continue; [ "$(cat "$n/operstate" 2>/dev/null)" = up ] && { I=$b; break; }; done
if [ -z "${I:-}" ] || [ ! -d "/sys/class/net/$I" ]; then printf '{"text":"","class":"network-disconnected","tooltip":"Disconnected"}\n'; exit 0; fi
now=$(date +%s%N); rx=$(cat "/sys/class/net/$I/statistics/rx_bytes" 2>/dev/null||echo 0); tx=$(cat "/sys/class/net/$I/statistics/tx_bytes" 2>/dev/null||echo 0)
pt=0 prx=0 ptx=0; [ -f "$S" ] && read -r pt prx ptx < "$S" 2>/dev/null || true
printf '%s %s %s\n' "$now" "$rx" "$tx" > "$S"
read -r DV DU UV UU < <(awk -v n="$now" -v pt="$pt" -v rx="$rx" -v prx="$prx" -v tx="$tx" -v ptx="$ptx" '
function f(x){if(x>=1048576){v=x/1048576;u="M"}else if(x>=1024){v=x/1024;u="K"}else{v=x;u="B"};printf "%.1f %s ",v,u}
BEGIN{dt=(n-pt)/1e9; if(pt==0||dt<=0){d=0;up=0}else{d=(rx-prx)/dt;up=(tx-ptx)/dt} if(d<0)d=0;if(up<0)up=0; f(d);f(up)}')
case "$M" in
  up)   T="↑ ${UV}${UU}";;
  down) T="↓ ${DV}${DU}";;
  unit) T="${DU}";;
  v)    T="↑${UV}\n↓${DV}";;
  *)    T="↓${DV}${DU} ↑${UV}${UU}";;
esac
printf '{"text":"%s","class":"network","tooltip":"↓ %s %s/s  ↑ %s %s/s (%s)"}\n' "$T" "$DV" "$DU" "$UV" "$UU" "$I"
