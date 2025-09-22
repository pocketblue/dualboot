#!/usr/bin/env bash

set -uexo pipefail

which adb
which fastboot

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep sdm845
fastboot erase op2 2> /dev/null || true
fastboot flash dtbo_a images/lineage_dtbo.img
fastboot flash boot_a images/twrp_enchilada.img
fastboot --set-active=a
fastboot reboot

adb wait-for-recovery
adb shell getprop ro.product.device | grep OnePlus6
until adb shell twrp unmount /data ; do sleep 1; done
adb push images/sgdisk /bin/sgdisk
adb push images/parted /bin/parted

# validating that sda17 partition is userdata
adb shell parted /dev/block/sda print | grep userdata | grep -qE '^17'

# partitioning
adb shell 'if [ -e /dev/block/sda17 ]; then sgdisk --delete=17 /dev/block/sda; fi'
adb shell 'if [ -e /dev/block/sda18 ]; then sgdisk --delete=18 /dev/block/sda; fi'
adb shell 'if [ -e /dev/block/sda19 ]; then sgdisk --delete=19 /dev/block/sda; fi'
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
adb shell mount /dev/block/by-name/vendor_b /mnt
adb shell 'sed -E -i "s/,?fileencryption=[^, ]*//g" /mnt/etc/fstab.qcom'
adb shell umount /mnt
adb shell twrp format data

# installing fedora root
adb shell rm -rf /data/.stowaways/fedora
adb shell mkdir -p /data/.stowaways/fedora
adb push images/fedora_root.raw.gz /data/.stowaways/fedora_root.raw.gz
adb shell gzip -d /data/.stowaways/fedora_root.raw.gz
adb shell mount -o loop,ro /data/.stowaways/fedora_root.raw /mnt
adb shell cp -a /mnt/ostree /data/.stowaways/fedora
adb shell mkdir -p /data/.stowaways/fedora/boot
adb shell umount /mnt
adb shell rm /data/.stowaways/fedora_root.raw
adb reboot fastboot

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep sdm845
fastboot erase dtbo_a
fastboot flash dtbo_b      images/lineage_dtbo.img
fastboot flash boot_a      images/uboot_enchilada.img
fastboot flash boot_b      images/lineage_boot.img
fastboot flash fedora_esp  images/fedora_esp.raw
fastboot flash fedora_boot images/fedora_boot.raw
