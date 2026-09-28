#!/usr/bin/env bash
# display-mode.sh: Windows-style display switcher (Super+P)
#
# Runs displayctl's presets: one layout for every screen, applied safely.
# A rofi "Keep changes / Revert" question follows; no answer in 15 s reverts.
# "Laptop only" is left out until displayctl's dock daemon (Phase 4): the
# saved docked layout would turn the Samsung straight back on.

DISPLAYCTL_DIR="$HOME/projects/displayctl"
LOG="${XDG_RUNTIME_DIR:-/tmp}/display-mode.log"

CHOICE=$(printf "External only\nExtend\n" | rofi -dmenu -i -no-custom -p "Display")

case "$CHOICE" in
    "External only") PRESET=external ;;
    "Extend")        PRESET=extend ;;
    *)               exit 0 ;;   # Escape: do nothing
esac

# Output goes to a log (there's no terminal); a failure shows a notification.
if ! "$DISPLAYCTL_DIR/.venv/bin/python" "$DISPLAYCTL_DIR/displayctl.py" preset "$PRESET" \
        </dev/null >"$LOG" 2>&1; then
    notify-send -u critical "Display switch failed" "$(tail -n 3 "$LOG")"
fi
