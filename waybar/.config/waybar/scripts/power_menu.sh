#!/bin/bash

choice=$(printf "  Lock\n  Suspend\n  Shutdown\n  Reboot\n󰍃  Logout" | \
  wofi --dmenu --insensitive --style ~/.config/wofi/power.css --width=250 --height=250)

case "$choice" in
  *Lock)     loginctl lock-session ;;
  *Suspend)  systemctl suspend ;;
  *Shutdown) systemctl poweroff ;;
  *Reboot)   systemctl reboot ;;
  *Logout)   hyprctl dispatch exit ;;
esac
