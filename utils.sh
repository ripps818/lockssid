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

# Function to check if Wi-Fi is locked
is_wifi_locked() {
    local bssid
    bssid=$(nmcli -f 802-11-wireless.bssid con show "$SSID" | tail -n1)
    [ -n "$bssid" ] && [ "$bssid" != "" ]  # Return true if BSSID is set
}

# Function to get BSSID from SSID
get_bssid_from_ssid() {
    local ssid="$1"
    nmcli -f 802-11-wireless.bssid con show "$ssid" | tail -n1
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
