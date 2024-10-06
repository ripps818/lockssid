#!/bin/bash

# Source the configuration file
CONF_FILE="$HOME/.config/LockSSID/lockssid.conf"
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "Error: Configuration file not found at $CONF_FILE"
    exit 1
fi

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

# Function to get the active Wi-Fi device
get_active_wifi_device() {
    nmcli -t -f DEVICE,TYPE device | grep ':wifi' | cut -d':' -f1 | head -n1
}

# Function to get the current SSID
get_current_ssid() {
    local wifi_device
    wifi_device=$(get_active_wifi_device)

    if [ -n "$wifi_device" ]; then
        nmcli device wifi list ifname "$wifi_device" | grep -m 1 '*' | awk '{print $3}'
    else
        log_message "No active Wi-Fi device found."
        return 1
    fi
}

# Function to get the current BSSID
get_current_bssid() {
    local wifi_device
    wifi_device=$(get_active_wifi_device)

    if [ -n "$wifi_device" ]; then
        nmcli device wifi list ifname "$wifi_device" | grep -m 1 '*' | awk '{print $2}'
    else
        log_message "No active Wi-Fi device found."
        return 1
    fi
}

# Function to check if Wi-Fi is locked
is_wifi_locked() {
    local ssid
    local bssid
    ssid=$(get_current_ssid)
    bssid=$(nmcli con show "$ssid" | grep -m1 802-11-wireless.bssid: | awk '{print $2}')
    if [ "$bssid" == "--" ]; then
        return 0
    else
       return 1
    fi
}

# Function to check running programs
check_running_programs() {
    for program in "${programs[@]}"; do
        if pgrep -x "$program" > /dev/null; then
            return 0  # At least one program is running
        fi
    done
    return 1  # No programs are running
}
