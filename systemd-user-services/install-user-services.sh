#!/bin/bash

set -e

# Directory this script resides in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/.config/systemd/user"

echo "🔧 Installing user services from: $SCRIPT_DIR"
mkdir -p "$DEST_DIR"

# Copy and overwrite .service files
echo "📂 Copying .service files to $DEST_DIR..."
find "$SCRIPT_DIR" -type f -name "*.service" | while read -r src; do
    cp -f "$src" "$DEST_DIR/"
    echo "✔ Copied: $(basename "$src")"
done

# Reload systemd user daemon to pick up changes
echo "🔄 Reloading systemd user daemon..."
systemctl --user daemon-reload

# Enable and start/restart each service
echo "🚀 Enabling and starting services..."
for service in "$DEST_DIR"/*.service; do
    name=$(basename "$service")
    systemctl --user enable --now "$name"
    echo "✅ Enabled and started: $name"
done
systemctl --user enable --now hyprpolkitagent.service
echo "✅ All services installed and activated."
