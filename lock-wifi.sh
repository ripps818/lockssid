#!/bin/bash

# Load utility functions
source ~/.local/share/LockSSID/utils.sh

# Get the current SSID
SSID=$(get_current_ssid)

if [ -z "$SSID" ]; then
    log_message "No active Wi-Fi connection found. Exiting."
    exit 1
fi

# Locking logic
log_message "Locking Wi-Fi for SSID: $SSID"
bssid=$(get_current_bssid)

if [ -n "$bssid" ]; then
    nmcli con mod "$SSID" 802-11-wireless.bssid "$bssid"
    log_message "Wi-Fi locked to BSSID: $bssid"
else
    log_message "Failed to retrieve BSSID for SSID: $SSID"
fi

# Optionally disconnect and reconnect
nmcli device disconnect "$SSID"
nmcli device connect "$SSID"
