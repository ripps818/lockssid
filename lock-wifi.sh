#!/bin/bash

# Log message function
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> /var/log/lockssid.log
}

# Get the current SSID
SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d':' -f2)

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
bssid=$(nmcli -t -f ACTIVE,BSSID dev wifi | grep '^yes:' | cut -d':' -f2)

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
nmcli device disconnect "$DEVICE_NAME"
nmcli device connect "$DEVICE_NAME"
