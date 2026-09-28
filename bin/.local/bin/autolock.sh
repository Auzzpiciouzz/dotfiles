#!/bin/sh
# Lock at startup only when greetd auto-logged us in (see /etc/greetd/config.toml)
[ -n "$HYPR_AUTOLOCK" ] && exec hyprlock
