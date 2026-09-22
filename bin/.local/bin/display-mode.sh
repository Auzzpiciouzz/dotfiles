#!/usr/bin/env bash
# display-mode.sh: Windows-style display switcher

CHOICE=$(printf "External only\nExtend\nLaptop only\n" | rofi -dmenu -i -p "Display")

case "$CHOICE" in
    "External only") kanshictl switch external ;;
    "Extend")        kanshictl switch extend ;;
    "Laptop only")   kanshictl switch laptop ;;
esac