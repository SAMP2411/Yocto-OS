#!/bin/bash
sync
sleep 1

# ==================================================================
# 1. CONFIGURATION
# ==================================================================
BASE_DIR="$HOME/yocto_13_12/build"
IMG="$BASE_DIR/tmp-musl/deploy/images/qemuarm/my-minimal-image-qemuarm.rootfs.wic"
KERNEL="$BASE_DIR/tmp-musl/deploy/images/qemuarm/zImage"
ENV_FILE="$BASE_DIR/boot_state.bin"

while true; do
    # --- AUTO-INITIALIZE IF DELETED ---
    if [ ! -f "$ENV_FILE" ]; then
        echo "⚠️  Boot Memory missing. Creating fresh state..."
        dd if=/dev/zero of="$ENV_FILE" bs=1k count=16 conv=notrunc 2>/dev/null
    fi

    echo "🔍 Scanning Boot Memory..."
    
    # Extract strings and clean nulls
    LATEST_ORDER=$(strings "$ENV_FILE" | tr -d '\0' | grep "BOOT_ORDER=" | tail -n 1)

    if [[ "$LATEST_ORDER" == *"B A"* ]]; then
        echo "✅ Detected Active Slot: B (Update Detected)"
        ROOT_PART="/dev/vda3"
    else
        echo "✅ Detected Active Slot: A (Default/Standard)"
        ROOT_PART="/dev/vda2"
    fi

    echo "🚀 Launching QEMU into $ROOT_PART..."

    qemu-system-arm \
        -device virtio-net-device,netdev=net0,mac=52:54:00:12:34:56 \
        -netdev user,id=net0 \
        -drive file="$IMG",format=raw,if=virtio,index=0,cache=writethrough \
        -drive file="$ENV_FILE",format=raw,if=virtio,index=1,cache=directsync \
        -device virtio-rng-pci \
        -machine virt,highmem=off \
        -cpu cortex-a15 \
        -m 256 \
        -serial mon:stdio \
        -nographic \
        -no-reboot \
        -kernel "$KERNEL" \
        -append "root=$ROOT_PART rw console=ttyAMA0,115200 ip=dhcp"

    echo "🔄 QEMU process finished. Syncing host buffers..."
    sync
    sleep 2
done
