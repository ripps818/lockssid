#!/bin/bash

# Variables
INSTALL_DIR="$HOME/.local/share/LockSSID"
CONF_DIR="$HOME/.config/LockSSID"

# Create necessary directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONF_DIR"

# Copy scripts to the install directory
cp "$0" "$INSTALL_DIR/monitor-wifi-lock.sh"
cp "$INSTALL_DIR/lock-wifi.sh" "$INSTALL_DIR/unlock-wifi.sh" "$INSTALL_DIR/utils.sh" "$CONF_DIR/lockssid.conf"

# Set up systemd service
cp "$INSTALL_DIR/LockSSID.service" "$HOME/.config/systemd/user/LockSSID.service"
systemctl --user enable LockSSID.service
systemctl --user start LockSSID.service

echo "LockSSID installed successfully."
