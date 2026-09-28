#!/bin/sh
# For hyprlock: "artist – title", or nothing when no player is running
playerctl metadata --format '󰎆  {{trunc(artist, 25)}} – {{trunc(title, 35)}}' 2>/dev/null
