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

# Locking logic with additional logging and validation
log_message "Attempting to lock Wi-Fi for SSID: $SSID"
bssid=$(nmcli -t -f ACTIVE,BSSID dev wifi | grep '^yes:' | cut -d':' -f2- | sed 's/\\:/:/g')

if [ -n "$bssid" ]; then
    log_message "Current BSSID for SSID $SSID: $bssid"
    nmcli con mod "$SSID" 802-11-wireless.bssid "$bssid"
    log_message "Wi-Fi locked to BSSID: $bssid"
else
    log_message "Failed to retrieve BSSID for SSID: $SSID"
    exit 1
fi

# Prevent NetworkManager from scanning for other networks
nmcli dev set "$DEVICE_NAME" managed no
log_message "Set NetworkManager to unmanaged for device: $DEVICE_NAME"

# Turn off power saving mode using nmcli
nmcli con mod "$SSID" 802-11-wireless.powersave 2
log_message "Turned off power saving mode for SSID: $SSID"

# Disconnect and reconnect if the device is active
if nmcli device status | grep -q "$DEVICE_NAME.*connected"; then
    log_message "Disconnecting and reconnecting device: $DEVICE_NAME"
    nmcli device disconnect "$DEVICE_NAME"
    nmcli device connect "$DEVICE_NAME"
    log_message "Reconnected device: $DEVICE_NAME"
else
    log_message "Device $DEVICE_NAME is not active. Skipping disconnect and reconnect."
fi
