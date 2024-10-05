#!/bin/bash

# Load utility functions
source "$HOME/.local/share/LockSSID/utils.sh"

# Load configuration file
source "$HOME/.config/LockSSID/lockssid.conf"

# Get the SSID from the configuration
SSID="$ssid"

# Unlock the Wi-Fi
nmcli con mod "$SSID" 802-11-wireless.bssid ''
nmcli dev connect "$(nmcli -t -f device,active dev | grep '^wifi' | cut -d: -f1)"

# Log the action
log_message "Unlocked Wi-Fi for SSID: $SSID"
