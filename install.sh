#!/bin/bash

# Variables
INSTALL_DIR="$HOME/.local/share/LockSSID"
CONF_DIR="$HOME/.config/LockSSID"
SYSTEMD_DIR="$HOME/.config/systemd/user"

mkdir -p "$INSTALL_DIR" && echo "Install directory created: $INSTALL_DIR"
mkdir -p "$CONF_DIR" && echo "Config directory created: $CONF_DIR"
mkdir -p "$SYSTEMD_DIR" && echo "Config directory created: $SYSTEMD_DIR"

# Install LockSSID scripts and configuration
install -m 755 lock-wifi.sh unlock-wifi.sh monitor-wifi-lock.sh utils.sh "$INSTALL_DIR/"
install -m 644 lockssid.conf "$CONF_DIR/"

# Install the systemd service file
install -m 644 LockSSID.service ~/.config/systemd/user/
if [ ! -f "$SYSTEMD_DIR/LockSSID.service" ]; then
  echo "Error: $SYSTEMD_DIR/LockSSID.service not found."
  exit 1
fi

systemctl --user enable LockSSID.service
systemctl --user start LockSSID.service

echo "LockSSID installed successfully."
