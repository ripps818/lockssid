#!/bin/bash

# Load utility functions
source "$HOME/.local/share/LockSSID/utils.sh"

# Load configuration file
source "$HOME/.config/LockSSID/lockssid.conf"

# Loop through SSIDs in the config
for SSID in "${ssids[@]}"; do
    # Get the BSSID based on the SSID
    BSSID=$(get_bssid_from_ssid "$SSID")

    if [ -n "$BSSID" ]; then
        # Lock Wi-Fi to the specified BSSID
        nmcli con mod "$SSID" 802-11-wireless.bssid "$BSSID"

        # Log success and break out of the loop
        log_message "Locked Wi-Fi to SSID: $SSID and BSSID: $BSSID"
        send_notification "Locked to SSID: $SSID" "Wi-Fi Lock"
        break
    else
        # Log the failure and continue to the next SSID
        log_message "Failed to lock Wi-Fi to SSID: $SSID"
    fi
done
