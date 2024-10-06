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
    local target_ssid="$1"
    
    # Find the active Wi-Fi device (exclude p2p-dev and disconnected devices)
    WIFI_DEVICE=$(nmcli device status | grep wifi | grep -v 'p2p-dev' | grep -v 'disconnected' | awk '{print $1}' | head -n 1)

    if [[ -z "$WIFI_DEVICE" ]]; then
        echo "No active Wi-Fi device found." >&2
        return 1
    fi

    # Get connection details for the Wi-Fi device
    LINK_INFO=$(iw dev "$WIFI_DEVICE" link)
    SSID=$(echo "$LINK_INFO" | grep 'SSID' | awk '{print $2}')
    
    # Check if the current SSID matches the one from the config file
    if [[ "$SSID" == "$target_ssid" ]]; then
        BSSID=$(echo "$LINK_INFO" | grep 'Connected to' | awk '{print $3}')
        echo "$BSSID"
        return 0
    else
        echo "SSID $target_ssid not currently connected." >&2
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
