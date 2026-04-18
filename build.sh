#!/bin/bash
# Build an out-of-tree kernel module for Xiaomi Mi Mix 3 (perseus)
# against the pre-extracted kernel headers in this repo.
#
# Usage:
#   ./build.sh <module_source_dir> [kernel_version]
#
# Example:
#   ./build.sh /path/to/qcacld-3.0
#   ./build.sh /path/to/qcacld-3.0 4.9.337-perf-g6d3a382ef236
#
# Requirements:
#   - Android clang toolchain (clang-r536225 or compatible)
#   - aarch64-linux-android- cross compiler (GCC 4.9)
#   - arm-linux-androideabi- cross compiler (GCC 4.9, for compat vDSO)
#
# These are available in the LineageOS/AOSP prebuilts directory.

set -e

MODULE_SRC="${1}"
KERNEL_VERSION="${2:-4.9.337-perf-g6d3a382ef236}"
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
    echo "Error: No headers found for kernel $KERNEL_VERSION"
    echo "Available: $(ls $SCRIPT_DIR/headers/)"
    exit 1
fi

# Auto-detect toolchain from ANDROID_BUILD_TOP or common paths
if [ -n "$ANDROID_BUILD_TOP" ]; then
    CLANG_BIN="$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r536225/bin"
    GCC_BIN="$ANDROID_BUILD_TOP/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin"
    GCC32_BIN="$ANDROID_BUILD_TOP/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin"
else
    # Fall back to PATH
    CLANG_BIN=""
    GCC_BIN=""
    GCC32_BIN=""
fi

CC="${CLANG_BIN:+$CLANG_BIN/}clang"
CROSS_COMPILE="${GCC_BIN:+$GCC_BIN/}aarch64-linux-android-"
CROSS_COMPILE_ARM32="${GCC32_BIN:+$GCC32_BIN/}arm-linux-androideabi-"

echo "================================================"
echo "  Perseus Kernel Module Builder"
echo "  Kernel:  $KERNEL_VERSION"
echo "  Source:  $MODULE_SRC"
echo "  Headers: $HEADERS_DIR"
echo "  Output:  $OUT_DIR"
echo "================================================"

mkdir -p "$OUT_DIR"

make -C "$HEADERS_DIR" \
    M="$(realpath $MODULE_SRC)" \
    ARCH=arm64 \
    CC="$CC" \
    CROSS_COMPILE="$CROSS_COMPILE" \
    CROSS_COMPILE_ARM32="$CROSS_COMPILE_ARM32" \
    LD=ld.lld \
    LLVM_IAS=1 \
    CONFIG_QCA_CLD_WLAN=m \
    modules

# Copy built .ko files to output directory
find "$(realpath $MODULE_SRC)" -name "*.ko" -exec cp {} "$OUT_DIR/" \;

echo ""
echo "Built modules:"
ls -lh "$OUT_DIR/"*.ko 2>/dev/null || echo "No .ko files found"
