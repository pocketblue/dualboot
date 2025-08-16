#!/usr/bin/env bash

set -uexo pipefail

mkdir images

curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-fajita.img -o images/uboot-fajita.img
curl -L https://mirrorbits.lineageos.org/full/fajita/20250812/boot.img -o images/lineage_boot.img
curl -L https://mirrorbits.lineageos.org/full/fajita/20250812/dtbo.img -o images/lineage_dtbo.img
curl -L https://github.com/gmankab/sgdisk/releases/download/v1.0.10/sgdisk -o images/sgdisk
curl -L https://github.com/gmankab/parted/releases/download/v3.6/parted -o images/parted
curl -L -e https://eu.dl.twrp.me/fajita https://eu.dl.twrp.me/fajita/twrp-3.7.0_9-0-fajita.img -o images/twrp-fajita.iml

curl -L https://mirrorbits.lineageos.org/full/fajita/20250812/lineage-22.2-20250812-nightly-fajita-signed.zip -o images/lineage_rom.zip

curl -LO https://github.com/pocketblue/pocketblue/releases/download/42.20250810/pocketblue-oneplus6-gnome-mobile-42.7z
7z x pocketblue-oneplus6-gnome-mobile-42.7z -o./pocketblue

cp pocketblue/images/boot.raw images/fedora_boot.raw
cp pocketblue/images/esp.raw images/fedora_esp.raw

mkdir root_raw
sudo mount -o ro,loop pocketblue/images/root.raw root_raw
sudo tar -C root_raw/root -cpf fedora_root.tar .
sudo chmod 666 fedora_root.tar
7z a -txz -mx=9 images/fedora_root.tar.xz fedora_root.tar

install -Dm 0755 oneplus6t/dualboot.sh dualboot_oneplus6t_fajita.sh

7z a -mx9 oneplus6t_dualboot.7z dualboot_oneplus6t_fajita.sh images
