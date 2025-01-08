#!/bin/bash

# Load utility functions
source "/etc/lockssid/utils.sh"

# Get the current SSID
SSID=$(get_current_ssid)

if [ -z "$SSID" ]; then
    log_message "No active Wi-Fi connection found. Exiting."
    exit 1
fi

# Get the wifi card's device name
DEVICE_NAME=$(iw dev | grep Interface | awk '{print $2}')

if [ -z "$DEVICE_NAME" ]; then
    log_message "No wireless device found. Exiting."
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

# Prevent NetworkManager from scanning for other networks
nmcli dev set "$DEVICE_NAME" managed no

# Turn off power saving mode
iw dev "$DEVICE_NAME" set power_save off

# Optionally disconnect and reconnect
nmcli device disconnect "$SSID"
nmcli device connect "$SSID"
