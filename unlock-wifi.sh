#!/bin/bash

# Load utility functions
source ~/.local/share/LockSSID/utils.sh

# Get the current SSID
SSID=$(get_current_ssid)

if [ -z "$SSID" ]; then
    log_message "No active Wi-Fi connection found. Exiting."
    exit 1
fi

# Unlocking logic
log_message "Unlocking Wi-Fi for SSID: $SSID"
nmcli con mod "$SSID" 802-11-wireless.bssid ''

# Optionally disconnect and reconnect
nmcli device disconnect "$SSID"
nmcli device connect "$SSID"
