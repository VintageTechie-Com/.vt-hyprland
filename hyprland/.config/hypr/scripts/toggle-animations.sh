#!/bin/bash

CONF="$HOME/.config/hypr/includes/animations.conf"

FAST="source = ~/.config/hypr/includes/ultrafast.conf"
NORMAL="source = ~/.config/hypr/includes/normal.conf"

current=$(<"$CONF")

if [[ "$current" == "$FAST" ]]; then
    echo "$NORMAL" > "$CONF"
    notify-send "Hyprland" "Switched to: 🟢 Normal Animations"
elif [[ "$current" == "$NORMAL" ]]; then
    echo "$FAST" > "$CONF"
    notify-send "Hyprland" "Switched to: ⚡ Ultra-Fast Animations"
else
    notify-send "Hyprland" "❌ Could not detect animation profile"
    echo "Unexpected content:"
    echo "'$current'"
    exit 1
fi

hyprctl reload
