#!/bin/bash

# Load utility functions
source "$HOME/.local/share/LockSSID/utils.sh"

# Load configuration file
source "$HOME/.config/LockSSID/lockssid.conf"

# Loop through SSIDs in the config
for SSID in "${ssids[@]}"; do
    # Clear the BSSID for the specified SSID, effectively unlocking it
    nmcli con mod "$SSID" 802-11-wireless.bssid ""

    # Check if the unlock command was successful
    if check_success "nmcli con mod $SSID 802-11-wireless.bssid"; then
        log_message "Unlocked Wi-Fi from SSID: $SSID"
        send_notification "Unlocked from SSID: $SSID" "Wi-Fi Unlock"
        break
    else
        log_message "Failed to unlock Wi-Fi from SSID: $SSID"
    fi
done
