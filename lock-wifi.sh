#!/bin/bash

# Load utility functions
source "$HOME/.local/share/LockSSID/utils.sh"

# Load configuration file
source "$HOME/.config/LockSSID/lockssid.conf"

# Get the SSID from the configuration
SSID="$ssid"

# Get the BSSID based on the SSID
BSSID=$(get_bssid_from_ssid "$SSID")

# Lock Wi-Fi to the specified BSSID
nmcli con mod "$SSID" 802-11-wireless.bssid "$BSSID"
nmcli dev connect "$(nmcli -t -f device,active dev | grep '^wifi' | cut -d: -f1)"

# Log the action
log_message "Locked Wi-Fi to BSSID: $BSSID"
