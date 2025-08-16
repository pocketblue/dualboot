#!/usr/bin/env bash

set -uexo pipefail

export device=enchilada

which adb
which fastboot

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep 'sdm845'
fastboot erase op2 2> /dev/null || true
fastboot flash dtbo_a images/lineage_dtbo.img
fastboot --set-active=a
fastboot boot images/ofox_$device.img

set +x
echo 'waiting for device appear in adb'
until adb devices 2>/dev/null | grep recovery --silent ; do sleep 1; done
set -x

adb shell getprop ro.product.device | grep $device
adb shell twrp unmount /data
adb push images/sgdisk /bin/sgdisk
adb push images/parted /bin/parted

# validating that sda17 partition is userdata
adb shell parted /dev/block/sda print | grep userdata | grep -qE '^17'

# partitioning
adb shell 'if [ -e /dev/block/sda17 ]; then parted -s /dev/block/sda rm 17; fi'
adb shell 'if [ -e /dev/block/sda18 ]; then parted -s /dev/block/sda rm 18; fi'
adb shell 'if [ -e /dev/block/sda19 ]; then parted -s /dev/block/sda rm 19; fi'
export start=$(adb shell parted -m /dev/block/sda print free | tail -1 | cut -d: -f2)
adb shell parted -s /dev/block/sda -- mkpart userdata    ext4 $start -3GB
adb shell parted -s /dev/block/sda -- mkpart fedora_boot ext4   -3GB -1GB
adb shell parted -s /dev/block/sda -- mkpart fedora_esp  fat32  -1GB 100%

# installing lineage os rom
adb push images/lineage_rom.zip /tmp/lineage_rom.zip
adb shell twrp format data
adb shell twrp install /tmp/lineage_rom.zip
adb shell rm /tmp/lineage_rom.zip

# installing fedora root
adb push images/fedora_root.tar.xz /tmp/fedora_root.tar.xz
adb shell rm -rf /data/.stowaways/fedora
adb shell mkdir -p /data/.stowaways/fedora
echo 'installing fedora root, this can be long'
adb shell tar -xJf /tmp/fedora_root.tar.xz -C /data/.stowaways/fedora
echo 'done installing fedora root'
adb shell rm /tmp/fedora_root.tar.xz
adb reboot bootloader

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep 'sdm845'
fastboot erase dtbo_a
fastboot flash dtbo_b      images/lineage_dtbo.img
fastboot flash boot_a      images/uboot_$device.img
fastboot flash boot_b      images/lineage_boot.img
fastboot flash fedora_esp  images/fedora_esp.raw
fastboot flash fedora_boot images/fedora_boot.raw

echo 'done flashing, rebooting now'
fastboot reboot
