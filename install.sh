#!/bin/bash
# Install kernel modules on perseus device via SSH
#
# Usage:
#   ./install.sh [distro] [kernel_version]
#
# Distros: sailfish (default), kali, ubuntu-touch
#
# The script:
#   1. Pushes wlan.ko to the correct /lib/modules path on device
#   2. Restarts wlan-module-load service (SFOS) or loads module directly
#
# Device must be reachable via SSH.

set -e

DISTRO="${1:-sailfish}"
KERNEL_VERSION="${2:-4.9.337-perf-g6d3a382ef236}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules/$KERNEL_VERSION"

# SSH config per distro
case "$DISTRO" in
    sailfish)
        SSH_HOST="192.168.2.15"
        SSH_PORT="2222"
        SSH_USER="root"
        ;;
    kali)
        SSH_HOST="192.168.2.15"
        SSH_PORT="22"
        SSH_USER="root"
        ;;
    ubuntu-touch)
        SSH_HOST="192.168.2.15"
        SSH_PORT="22"
        SSH_USER="phablet"
        ;;
    *)
        echo "Unknown distro: $DISTRO"
        echo "Usage: $0 [sailfish|kali|ubuntu-touch] [kernel_version]"
        exit 1
        ;;
esac

SSH="ssh $SSH_USER@$SSH_HOST -p $SSH_PORT"
SCP="scp -P $SSH_PORT"

if [ ! -d "$MODULES_DIR" ]; then
    echo "Error: No modules built for kernel $KERNEL_VERSION"
    echo "Run ./build.sh first"
    exit 1
fi

KO_FILES=$(ls "$MODULES_DIR"/*.ko 2>/dev/null)
if [ -z "$KO_FILES" ]; then
    echo "Error: No .ko files in $MODULES_DIR"
    exit 1
fi

echo "Installing modules for $DISTRO (kernel $KERNEL_VERSION)"
echo "Target: $SSH_USER@$SSH_HOST:$SSH_PORT"

# Create module directory on device
$SSH "mkdir -p /lib/modules/$KERNEL_VERSION"

# Copy all .ko files
for ko in $KO_FILES; do
    echo "  Pushing $(basename $ko)..."
    $SCP "$ko" "$SSH_USER@$SSH_HOST:/lib/modules/$KERNEL_VERSION/"
done

# Update module deps and load
$SSH "depmod -a $KERNEL_VERSION"

# Distro-specific activation
case "$DISTRO" in
    sailfish)
        echo "Restarting wlan-module-load..."
        $SSH "systemctl restart wlan-module-load && sleep 2 && ip link show wlan0"
        ;;
    kali|ubuntu-touch)
        echo "Loading wlan module..."
        $SSH "modprobe wlan && ip link show wlan0"
        ;;
esac

echo "Done."
