#!/bin/bash

# Source utility functions and configuration file
source "$HOME/.local/share/LockSSID/utils.sh"
CONF_FILE="$HOME/.config/LockSSID/lockssid.conf"
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "Error: Configuration file not found at $CONF_FILE"
    exit 1
fi

# Path to scripts
lock_wifi="$HOME/.local/share/LockSSID/lock-wifi.sh"
unlock_wifi="$HOME/.local/share/LockSSID/unlock-wifi.sh"

# Function to monitor Wi-Fi status
monitor_wifi() {
    local current_ssid
    local current_bssid
    local is_locked

    while true; do
        # Get current SSID and BSSID
        current_ssid=$(get_current_ssid)
        current_bssid=$(get_current_bssid)

        # Check if Wi-Fi is locked
        is_wifi_locked
        is_locked=$?

        # Check if any monitored programs are running
        if check_running_programs; then
            # If a monitored program is running and Wi-Fi is unlocked, lock it
            if [ $is_locked -eq 0 ]; then
                log_message "Locking Wi-Fi for SSID: $current_ssid"
                exec $lock_wifi
            else
                log_message "Wi-Fi is already locked for SSID: $current_ssid"
            fi
        else
            # If no programs are running and Wi-Fi is locked, unlock it
            if [ $is_locked -eq 1 ]; then
                log_message "Unlocking Wi-Fi for SSID: $current_ssid"
                exec $unlock_wifi
            else
                log_message "No monitored programs are running. Wi-Fi remains unlocked."
            fi
        fi

        # Sleep for the defined scan interval
        sleep "$scan_interval"
    done
}

# Start monitoring
monitor_wifi
