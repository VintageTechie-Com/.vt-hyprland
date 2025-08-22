#!/bin/bash
# Start gnome-keyring-daemon for secrets, ssh, gpg
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
export SSH_AUTH_SOCK
