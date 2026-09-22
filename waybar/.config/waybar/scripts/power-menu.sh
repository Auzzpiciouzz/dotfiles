#!/usr/bin/env bash
export PATH="/usr/bin:/usr/local/bin:$PATH"
# Power profile switcher (power-profiles-daemon) — opens in a terminal
command -v powerprofilesctl >/dev/null || { echo "power-profiles-daemon not installed"; sleep 2; exit 1; }
cur=$(powerprofilesctl get 2>/dev/null || echo unknown)
echo "Current profile: $cur"; echo
echo "  1) Power Saver"; echo "  2) Balanced"; echo "  3) Performance"; echo
read -rp "Choose [1-3, anything else = cancel]: " c
case "$c" in
  1) powerprofilesctl set power-saver ;;
  2) powerprofilesctl set balanced ;;
  3) powerprofilesctl set performance 2>/dev/null || echo "performance not available on this hardware" ;;
  *) echo "No change"; sleep 1; exit 0 ;;
esac
echo "Now: $(powerprofilesctl get)"; sleep 1
