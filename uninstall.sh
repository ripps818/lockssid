#!/bin/bash

# Variables
INSTALL_DIR="$HOME/.local/share/LockSSID"
CONF_DIR="$HOME/.config/LockSSID"

# Stop the service
systemctl --user stop LockSSID.service
systemctl --user disable LockSSID.service

# Remove service file
rm -f "$HOME/.config/systemd/user/LockSSID.service"

# Ask to remove configuration files
read -p "Do you want to remove the configuration files? (y/n): " choice
if [[ "$choice" == "y" ]]; then
    rm -rf "$CONF_DIR"
fi

# Remove scripts
rm -rf "$INSTALL_DIR"

echo "LockSSID uninstalled successfully."
