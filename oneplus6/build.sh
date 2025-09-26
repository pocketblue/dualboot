#!/usr/bin/env bash

set -uexo pipefail

rm -rf build
mkdir build
cp -r images build
cd build

curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-$codename.img -o images/uboot_$codename.img
curl -L -e https://dl.twrp.me/$codename https://dl.twrp.me/$codename/twrp-$twrp-$codename.img -o images/twrp_$codename.img

curl -L https://mirrorbits.lineageos.org/full/$codename/$lineage_build/boot.img -o images/lineage_boot.img
curl -L https://mirrorbits.lineageos.org/full/$codename/$lineage_build/dtbo.img -o images/lineage_dtbo.img
curl -L https://mirrorbits.lineageos.org/full/$codename/$lineage_build/lineage-22.2-$lineage_build-nightly-$codename-signed.zip -o images/lineage_rom.zip

install -Dm 0755 ../oneplus6/flash_oneplus6_fedora_lineage_dualboot.sh flash_${model}_${codename}_fedora_lineage_dualboot.sh
sed -i s/@device_codename@/$codename/g flash_${model}_${codename}_fedora_lineage_dualboot.sh
7z a -mx9 ${model}_${codename}_fedora_lineage_dualboot.7z images flash_${model}_${codename}_fedora_lineage_dualboot.sh
