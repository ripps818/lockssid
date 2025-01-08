#!#!/bin/bash

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

# Unlocking logic
log_message "Unlocking Wi-Fi for SSID: $SSID"
nmcli con mod "$SSID" 802-11-wireless.bssid ''

# Re-enable NetworkManager scanning for other networks
nmcli dev set "$DEVICE_NAME" managed yes

# Turn on power saving mode
iw dev "$DEVICE_NAME" set power_save on

# Optionally disconnect and reconnect
nmcli device disconnect "$SSID"
nmcli device connect "$SSID"
