#!/usr/bin/env bash

set -uexo pipefail

# check denpendncies
which 7z
which git
which curl
which gzip
which python

# download lineage os
curl -L https://github.com/dev-harsh1998/ota/releases/download/v1.5.2-qpr1-feb/boot.img -o images/lineage_boot.img
curl -L https://github.com/dev-harsh1998/ota/releases/download/v1.5.2-qpr1-feb/dtbo.img -o images/lineage_dtbo.img
curl -L https://github.com/dev-harsh1998/ota/releases/download/v1.5.2-qpr1-feb/lineage-22.1-20250207-UNOFFICIAL-nabu.zip -o images/lineage_rom.zip
curl -L https://github.com/ArKT-7/twrp_device_xiaomi_nabu/releases/download/mod_linux/V4-MODDED-TWRP-LINUX.img -o images/twrp.img

# download uboot
curl -L https://gitlab.com/sm8150-mainline/u-boot/-/jobs/10969839675/artifacts/download -o uboot.zip
7z x uboot.zip -o./uboot
cp uboot/.output/u-boot.img images/uboot.img

# generate vbmeta_disabled
git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output images/vbmeta_disabled.img

# patch vendor_boot to disable encryption
bash mipad5/lineage/disable_encryption.sh

# pack archive
install -Dm 0755 mipad5/lineage/flash_mipad5_fedora_lineage_dualboot.sh flash_mipad5_fedora_lineage_dualboot.sh
7z a -mx9 mipad5_fedora_lineage_dualboot.7z images flash_mipad5_fedora_lineage_dualboot.sh
