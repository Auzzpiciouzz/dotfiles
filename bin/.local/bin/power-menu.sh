#!/usr/bin/env bash
# power-menu.sh: lock, suspend, log out, reboot, shut down

CHOICE=$(printf "%s\n" \
  $'\uf023  Lock' \
  $'\uf186  Suspend' \
  $'\uf2f5  Log out' \
  $'\uf2f9  Reboot' \
  $'\uf011  Shut down' \
  | rofi -dmenu -i -p "Power")

confirm() {
  [ "$(printf "No\nYes\n" | rofi -dmenu -i -p "$1?")" = "Yes" ]
}

logout() {
  if command -v hyprshutdown >/dev/null 2>&1; then
    hyprshutdown
  else
    hyprctl dispatch 'hl.dsp.exit()'
  fi
}

case "$CHOICE" in
  *Lock*)        loginctl lock-session ;;
  *Suspend*)     systemctl suspend ;;
  *"Log out"*)   confirm "Log out" && logout ;;
  *Reboot*)      confirm "Reboot" && systemctl reboot ;;
  *"Shut down"*) confirm "Shut down" && systemctl poweroff ;;
esac
