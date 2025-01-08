#!/bin/bash

# Variables
INSTALL_DIR="/etc/lockssid"
SYSTEMD_DIR="/etc/systemd/system"
SERVICE_FILE="lockssid.service"
OLD_INSTALL_DIR="$HOME/.local/share/LockSSID"
OLD_CONF_DIR="$HOME/.config/LockSSID"
OLD_SERVICE_FILE="LockSSID.service"
REMOVE_OLD=false

# Function to remove old user configs and folders
remove_old_configs() {
    if [ -d "$OLD_INSTALL_DIR" ]; then
        rm -rf "$OLD_INSTALL_DIR" && echo "Old install directory removed: $OLD_INSTALL_DIR"
    fi
    if [ -d "$OLD_CONF_DIR" ]; then
        rm -rf "$OLD_CONF_DIR" && echo "Old config directory removed: $OLD_CONF_DIR"
    fi
    if [ -f "$SYSTEMD_DIR/$OLD_SERVICE_FILE" ]; then
        sudo systemctl stop "$OLD_SERVICE_FILE"
        sudo systemctl disable "$OLD_SERVICE_FILE"
        sudo rm -f "$SYSTEMD_DIR/$OLD_SERVICE_FILE"
        echo "Old service file removed: $OLD_SERVICE_FILE"
    fi
}

# Function to install LockSSID
install_lockssid() {
    if [ "$REMOVE_OLD" = true ]; then
        remove_old_configs
    fi

    sudo mkdir -p "$INSTALL_DIR" && echo "Install directory created: $INSTALL_DIR"

    # Check if the config file already exists
    if [[ -f "$INSTALL_DIR/lockssid.conf" ]]; then
        read -p "Configuration file already exists. Do you want to overwrite it? (y/n): " overwrite
        if [[ "$overwrite" != "y" ]]; then
            echo "Skipping configuration file overwrite."
        else
            echo "Overwriting configuration file."
            sudo install -m 644 lockssid.conf "$INSTALL_DIR/"
        fi
    else
        echo "Installing configuration file."
        sudo install -m 644 lockssid.conf "$INSTALL_DIR/"
    fi

    # Install LockSSID scripts
    sudo install -m 755 lock-wifi.sh unlock-wifi.sh monitor-wifi-lock.sh utils.sh "$INSTALL_DIR/"

    # Ensure scripts have execute permissions
    sudo chmod +x "$INSTALL_DIR/lock-wifi.sh"
    sudo chmod +x "$INSTALL_DIR/unlock-wifi.sh"
    sudo chmod +x "$INSTALL_DIR/monitor-wifi-lock.sh"
    sudo chmod +x "$INSTALL_DIR/utils.sh"

    # Install the systemd service file
    sudo install -m 644 "$SERVICE_FILE" "$SYSTEMD_DIR/"
    if [ ! -f "$SYSTEMD_DIR/$SERVICE_FILE" ]; then
        echo "Error: $SYSTEMD_DIR/$SERVICE_FILE not found."
        exit 1
    fi

    sudo systemctl enable "$SERVICE_FILE"
    sudo systemctl start "$SERVICE_FILE"

    echo "LockSSID installed successfully."
}

# Function to uninstall LockSSID
uninstall_lockssid() {
    sudo systemctl stop "$SERVICE_FILE"
    sudo systemctl disable "$SERVICE_FILE"
    sudo rm -f "$SYSTEMD_DIR/$SERVICE_FILE"
    sudo rm -rf "$INSTALL_DIR"
    echo "LockSSID uninstalled successfully."
}

# Parse flags
for arg in "$@"; do
    case $arg in
        -u|--uninstall)
        uninstall_lockssid
        exit 0
        ;;
        --remove-old)
        REMOVE_OLD=true
        ;;
    esac
done

install_lockssid
