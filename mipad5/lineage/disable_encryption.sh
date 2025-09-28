#!/usr/bin/env bash

set -uexo pipefail

# check dependencies
which 7z
which git
which curl
which cpio
which gzip
which python

# unpack image
curl -LO https://github.com/dev-harsh1998/ota/releases/download/v1.5.2-qpr1-feb/vendor_boot.img
git clone --depth 1 https://android.googlesource.com/platform/system/tools/mkbootimg
python mkbootimg/unpack_bootimg.py --boot_img vendor_boot.img
gzip -dc out/vendor_ramdisk > ramdisk.cpio

# patch image
mkdir patched
cd patched
cpio -idmv < ../ramdisk.cpio
git apply ../disable_encryption.patch
find . | cpio -o -H newc | gzip -9 > ../patched_vendor_ramdisk.cpio.gz
cd ..

# pack patched image
eval set -- $(python mkbootimg/unpack_bootimg.py --boot_img vendor_boot.img --out out --format=mkbootimg | sed -E 's/--vendor_ramdisk[[:space:]]+[^[:space:]]+//g')
python mkbootimg/mkbootimg.py "$@" --vendor_ramdisk patched_vendor_ramdisk.cpio.gz --vendor_boot images/vendor_boot_noencrypt.img
