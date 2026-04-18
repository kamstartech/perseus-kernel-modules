#!/bin/bash
# Native build script — run ON the device (arm64) inside Kali/SFOS namespace
# No cross-compilation needed since we're building on arm64 for arm64.
#
# Usage (inside Kali namespace):
#   git clone https://github.com/kamstartech/perseus-kernel-modules
#   cd perseus-kernel-modules
#   apt install gcc make bc libssl-dev -y
#   ./build-native.sh /path/to/qcacld-3.0

set -e

MODULE_SRC="${1}"
KERNEL_VERSION="${2:-$(uname -r)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HEADERS_DIR="$SCRIPT_DIR/headers/$KERNEL_VERSION"
OUT_DIR="$SCRIPT_DIR/modules/$KERNEL_VERSION"

if [ -z "$MODULE_SRC" ]; then
    echo "Usage: $0 <module_source_dir> [kernel_version]"
    echo ""
    echo "Available kernel versions:"
    ls "$SCRIPT_DIR/headers/"
    exit 1
fi

if [ ! -d "$HEADERS_DIR" ]; then
    echo "Error: No headers for kernel $KERNEL_VERSION"
    echo "Available: $(ls $SCRIPT_DIR/headers/)"
    exit 1
fi

echo "================================================"
echo "  Perseus Native Module Builder (on-device)"
echo "  Kernel:  $KERNEL_VERSION"
echo "  Source:  $MODULE_SRC"
echo "================================================"

mkdir -p "$OUT_DIR"

# Native build — no CROSS_COMPILE, no ARCH override needed
make -C "$HEADERS_DIR" \
    M="$(realpath $MODULE_SRC)" \
    CONFIG_QCA_CLD_WLAN=m \
    modules

find "$(realpath $MODULE_SRC)" -name "*.ko" -exec cp {} "$OUT_DIR/" \;

echo "Built modules:"
ls -lh "$OUT_DIR/"*.ko 2>/dev/null
