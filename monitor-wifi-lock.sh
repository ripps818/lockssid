#!/bin/bash

# Load the utility functions
source "$HOME/.local/share/LockSSID/utils.sh"

# Load configuration variables
source "$HOME/.config/LockSSID/lockssid.conf"

# Monitor running programs and lock/unlock Wi-Fi accordingly
monitor_wifi() {
    while true; do
        if check_running_programs; then
            if ! is_wifi_locked; then
                lock_wifi
            fi
        else
            if is_wifi_locked; then
                unlock_wifi
                sleep "$unlock_delay"
            fi
        fi
        sleep "$scan_interval"
    done
}

monitor_wifi
