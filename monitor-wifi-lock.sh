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

# Set card to unlocked when we first start.
bash $unlock_wifi

# Function to monitor Wi-Fi status
monitor_wifi() {
    local current_ssid
    local is_locked
    local was_locked=0
    local last_programs_running=0

    while true; do
        # Get current SSID
        current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d':' -f2)

        # Check if Wi-Fi is locked
        is_locked=$(nmcli -t -f 802-11-wireless.bssid con show "$current_ssid" | grep -c '802-11-wireless.bssid')

        # Check if any monitored programs are running
        if check_running_programs; then
            programs_running=1
        else
            programs_running=0
        fi

        # Lock or unlock Wi-Fi based on the state of monitored programs
        if [ "$programs_running" -eq 1 ] && [ "$last_programs_running" -eq 0 ]; then
            if [ "$is_locked" -eq 0 ]; then
                log_message "Locking Wi-Fi for SSID: $current_ssid"
                bash $lock_wifi
                was_locked=1
            else
                log_message "Wi-Fi is already locked for SSID: $current_ssid"
            fi
        elif [ "$programs_running" -eq 0 ] && [ "$last_programs_running" -eq 1 ]; then
            if [ "$is_locked" -eq 1 ]; then
                log_message "Unlocking Wi-Fi for SSID: $current_ssid"
                bash $unlock_wifi
                was_locked=0
            else
                log_message "Wi-Fi is already unlocked for SSID: $current_ssid"
            fi
        fi

        last_programs_running=$programs_running

        # Sleep for the defined scan interval
        sleep "$scan_interval"
    done
}

# Start monitoring
monitor_wifi
