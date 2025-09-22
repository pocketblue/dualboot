#!/usr/bin/env bash

set -uexo pipefail

cp -r ../images ./images
curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-fajita.img -o images/uboot-fajita.img
curl -L -e https://eu.dl.twrp.me/fajita https://eu.dl.twrp.me/fajita/twrp-3.7.0_9-0-fajita.img -o images/twrp-fajita.iml
curl -L https://mirrorbits.lineageos.org/full/fajita/20250916/boot.img -o images/lineage_boot.img
curl -L https://mirrorbits.lineageos.org/full/fajita/20250916/dtbo.img -o images/lineage_dtbo.img
curl -L https://mirrorbits.lineageos.org/full/fajita/20250916/lineage-22.2-20250916-nightly-fajita-signed.zip -o images/lineage_rom.zip
install -Dm 0755 dualboot.sh dualboot_oneplus6t_fajita.sh

7z a -mx9 dualboot_oneplus6t.7z dualboot_oneplus6t_fajita.sh images
