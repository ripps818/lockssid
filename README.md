# LockSSID

LockSSID is a tool designed to manage your Wi-Fi connection by locking it to a specific BSSID (Basic Service Set Identifier) based on the programs running on your system. This can help ensure a stable connection to a preferred Wi-Fi network. The service monitors specified programs and locks the Wi-Fi to a predefined BSSID when these programs are running. Once the programs are no longer running, the Wi-Fi is unlocked, allowing connections to other available networks.

## Installation and Usage

Run `install.sh` to install, and `uninstall.sh` to remove the tool.

### Configuration

Edit `/etc/lockssid/lockssid.conf` to change the list of monitored programs and other parameters such as unlocking delay and the time between scan intervals.

## Flags

- `-u`, `--uninstall`: Uninstall LockSSID.
- `--remove-old`: Remove old user configs and folders.

### Example

To install the tool:
```
./install.sh
```

To uninstall the tool:
```
./install.sh --uninstall
```

To remove old user configs and folders:
```
./install.sh --remove-old
```
