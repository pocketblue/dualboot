#!/usr/bin/env bash

set -uexo pipefail

which adb
which fastboot

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep nabu
fastboot flash vbmeta_ab     images/vbmeta_disabled.img
fastboot flash dtbo_ab       images/lineage_dtbo.img
fastboot flash vendor_boot_b images/lineage_vendor_boot.img
fastboot flash boot_b        images/lineage_boot.img
fastboot flash boot_a        images/twrp.img
fastboot --set-active=a
fastboot reboot

echo 'waiting for device appear in adb'
adb wait-for-recovery
adb shell getprop ro.product.device | grep nabu
adb shell twrp unmount /data
adb push images/sgdisk /bin/sgdisk
adb push images/parted /bin/parted
adb shell sgdisk --resize-table 64 /dev/block/sda

# validating that sda31 partition is userdata
adb shell parted /dev/block/sda print | grep userdata | grep -qE '^31'

# partitioning
adb shell "if [ -e /dev/block/sda31 ]; then sgdisk --delete=31 /dev/block/sda; fi"
adb shell "if [ -e /dev/block/sda32 ]; then sgdisk --delete=32 /dev/block/sda; fi"
adb shell "if [ -e /dev/block/sda33 ]; then sgdisk --delete=33 /dev/block/sda; fi"
adb shell "if [ -e /dev/block/sda34 ]; then sgdisk --delete=34 /dev/block/sda; fi"
adb shell "if [ -e /dev/block/sda35 ]; then sgdisk --delete=35 /dev/block/sda; fi"
export start=$(adb shell parted -m /dev/block/sda print free | tail -1 | cut -d: -f2)
adb shell parted -s /dev/block/sda -- mkpart userdata    ext4 $start -3GB
adb shell parted -s /dev/block/sda -- mkpart fedora_boot ext4   -3GB -1GB
adb shell parted -s /dev/block/sda -- mkpart fedora_esp  fat32  -1GB 100%

# installing lineage os rom on slot b
adb push images/lineage_rom.zip /tmp/lineage_rom.zip
adb shell twrp format data
echo 'installing lineage os rom on slot b'
echo 'you can check progress on screen of your device'
adb shell twrp install /tmp/lineage_rom.zip
adb shell rm /tmp/lineage_rom.zip

# disable encryption on slot b
adb shell mount /dev/block/by-name/vendor_boot_b /mnt
export disabled_encryption='/dev/block/bootdevice/by-name/userdata /data f2fs noatime,nosuid,nodev,discard,reserve_root=32768,resgid=1065,fsync_mode=nobarrier latemount,wait,check,formattable,quota,reservedsize=128M,checkpoint=fs,readahead_size_kb=128'
adb shell "sed -i '/userdata/s|.*|$disabled_encryption|' /mnt/first_stage_ramdisk/fstab.qcom"
adb shell umount /mnt
adb shell twrp format data

# installing fedora root
adb push images/fedora_root.tar.gz /tmp
echo 'unarchiving fedora_root.raw'
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
