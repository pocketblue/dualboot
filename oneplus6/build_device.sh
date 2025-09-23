#!/usr/bin/env bash

set -uexo pipefail

mkdir $device
cp -r images $device
cd $device

curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-$device.img -o images/uboot_$device.img
curl -L -e https://dl.twrp.me/$device https://dl.twrp.me/$device/twrp-3.7.0_11-0-$device.img -o images/twrp_$device.img

curl -L https://mirrorbits.lineageos.org/full/$device/$lineage_build/boot.img -o images/lineage_boot.img
curl -L https://mirrorbits.lineageos.org/full/$device/$lineage_build/dtbo.img -o images/lineage_dtbo.img
curl -L https://mirrorbits.lineageos.org/full/$device/$lineage_build/lineage-22.2-$lineage_build-nightly-$device-signed.zip -o images/lineage_rom.zip

install -Dm 0755 ../oneplus6/flash_dualboot.sh flash_${model}_${device}_fedora_lineage_dualboot.sh
sed -i s/@device@/$device/g flash_${model}_${device}_fedora_lineage_dualboot.sh
7z a -mx0 ${model}_${device}_fedora_lineage_dualboot.7z images flash_${model}_${device}_fedora_lineage_dualboot.sh
