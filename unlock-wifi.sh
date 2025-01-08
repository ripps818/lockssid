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

# Unlocking logic with additional logging
log_message "Unlocking Wi-Fi for SSID: $SSID"
nmcli con mod "$SSID" 802-11-wireless.bssid ''
log_message "Cleared BSSID lock for SSID: $SSID"

# Turn on power saving mode using nmcli
nmcli con mod "$SSID" 802-11-wireless.powersave 3
log_message "Turned on power saving mode for SSID: $SSID"

# Disconnect and reconnect if the device is active
if nmcli device status | grep -q "$DEVICE_NAME.*connected"; then
    log_message "Disconnecting and reconnecting device: $DEVICE_NAME"
    nmcli device disconnect "$DEVICE_NAME"
    nmcli device connect "$DEVICE_NAME"
    log_message "Reconnected device: $DEVICE_NAME"
else
    log_message "Device $DEVICE_NAME is not active. Skipping disconnect and reconnect."
fi
