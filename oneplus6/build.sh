#!/usr/bin/env bash

set -uexo pipefail

cp -r ../images ./images
curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-enchilada.img -o images/uboot_enchilada.img
curl -L -e https://dl.twrp.me/enchilada https://dl.twrp.me/enchilada/twrp-3.7.0_11-0-enchilada.img -o images/twrp_enchilada.img
curl -L https://mirrorbits.lineageos.org/full/enchilada/20250917/boot.img -o images/lineage_boot.img
curl -L https://mirrorbits.lineageos.org/full/enchilada/20250917/dtbo.img -o images/lineage_dtbo.img
curl -L https://mirrorbits.lineageos.org/full/enchilada/20250917/lineage-22.2-20250917-nightly-enchilada-signed.zip -o images/lineage_rom.zip
install -Dm 0755 flash_dualboot.sh dualboot_oneplus6_enchilada.sh

7z a -mx9 dualboot_oneplus6.7z dualboot_oneplus6_enchilada.sh images
