#!/bin/bash

# Configuration file
CONF_FILE="/etc/lockssid/lockssid.conf"
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "Error: Configuration file not found at $CONF_FILE"
    exit 1
fi

# Path to scripts
lock_wifi="/etc/lockssid/lock-wifi.sh"
unlock_wifi="/etc/lockssid/unlock-wifi.sh"

# Log message function
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> /var/log/lockssid.log
}

# Function to check if any monitored programs are running
check_running_programs() {
    for program in "${programs[@]}"; do
        if pgrep -f "$program" > /dev/null; then
            return 0
        fi
    done
    return 1
}

# Function to monitor Wi-Fi status
monitor_wifi() {
    local current_ssid
    local is_locked

    while true; do
        # Get current SSID
        current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d':' -f2)

        # Check if Wi-Fi is locked
        is_locked=$(nmcli -t -f 802-11-wireless.bssid con show "$current_ssid" | grep -c '802-11-wireless.bssid')

        # Check if any monitored programs are running
        if check_running_programs; then
            # If a monitored program is running and Wi-Fi is unlocked, lock it
            if [ "$is_locked" -eq 0 ]; then
                log_message "Locking Wi-Fi for SSID: $current_ssid"
                bash $lock_wifi
            else
                log_message "Wi-Fi is already locked for SSID: $current_ssid"
            fi
        else
            # If no programs are running and Wi-Fi is locked, unlock it
            if [ "$is_locked" -eq 1 ]; then
                log_message "Unlocking Wi-Fi for SSID: $current_ssid"
                bash $unlock_wifi
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
