#!/usr/bin/env bash

set -uexo pipefail

which adb
which fastboot

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep nabu
fastboot flash vbmeta_ab     images/vbmeta_disabled.img
fastboot flash dtbo_ab       images/lineage_dtbo.img
fastboot flash boot_b        images/lineage_boot.img
fastboot flash boot_a        images/twrp.img
fastboot --set-active=a
fastboot reboot

echo 'waiting for device appear in adb'
adb wait-for-recovery
adb shell getprop ro.product.device | grep nabu

# validating that sda31 partition is userdata
adb shell parted /dev/block/sda print | grep userdata | grep -qE '^31'

# installing fedora root
adb push images/fedora_root.tar.gz /tmp
echo 'unarchiving fedora_root.raw'
adb shell rm -rf /data/ostree
adb shell tar -xzf /tmp/fedora_root.tar.gz -C /data
adb reboot bootloader

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep nabu
fastboot erase dtbo_a
fastboot flash boot_a        images/uboot.img
fastboot flash fedora_esp    images/fedora_esp.raw
fastboot flash fedora_boot   images/fedora_boot.raw

echo 'done flashing, rebooting now'
fastboot reboot
