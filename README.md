# perseus-kernel-modules

Out-of-tree kernel modules for **Xiaomi Mi Mix 3 (perseus)**, built against the LineageOS 22.2 / Android 15 kernel (`4.9.337-perf`).

Supports SailfishOS, Kali NetHunter, and Ubuntu Touch running on this device.

## Pre-built Modules

| Module | Kernel | Description |
|---|---|---|
| `wlan.ko` | 4.9.337-perf-g6d3a382ef236 | Qualcomm qcacld-3.0 WiFi driver |

## Quick Install (pre-built)

```bash
# SailfishOS (USB SSH)
./install.sh sailfish

# Kali NetHunter
./install.sh kali

# Ubuntu Touch
./install.sh ubuntu-touch
```

## Build from Source

Requires the LineageOS build environment with Android prebuilt toolchains.

```bash
# Set up Android build env first
source build/envsetup.sh && breakfast perseus

# Build wlan.ko
./build.sh /path/to/android/kernel/xiaomi/sdm845/drivers/staging/qcacld-3.0

# Output: modules/4.9.337-perf-g6d3a382ef236/wlan.ko
```

## Headers

`headers/<kernel-version>/` contains the generated kernel headers extracted from
`KERNEL_OBJ` — enough to build any out-of-tree module without the full Android tree:

```
headers/4.9.337-perf-g6d3a382ef236/
├── .config          ← exact kernel config
├── Module.symvers   ← exported kernel symbols
├── include/         ← generated headers
└── arch/arm64/include/  ← arm64 generated headers
```

## Device Info

- **Device:** Xiaomi Mi Mix 3 (codename: perseus)
- **SoC:** Qualcomm SDM845
- **Kernel:** 4.9.337-perf (Android 15 / LineageOS 22.2)
- **WiFi chip:** Qualcomm WCN3990 (qcacld-3.0 driver)
