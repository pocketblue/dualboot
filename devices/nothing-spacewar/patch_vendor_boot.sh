#!/usr/bin/env bash

set -uexo pipefail

# check dependencies
which 7z
which git
which lz4
which curl
which cpio
which python

export patch=$(readlink -f devices/nothing-spacewar/ext4_noencrypt.patch)

# unpack image
curl -LO https://mirrorbits.lineageos.org/full/Spacewar/20251022/vendor_boot.img
git clone --depth 1 https://android.googlesource.com/platform/system/tools/mkbootimg
python mkbootimg/unpack_bootimg.py --boot_img vendor_boot.img
lz4 -dc out/vendor_ramdisk > ramdisk.cpio

# patch image
mkdir vb_patched
cd vb_patched
cpio -idmv < ../ramdisk.cpio
env --chdir=first_stage_ramdisk/system git apply $patch
find . | cpio -o -H newc | lz4 -z -9 - ../patched_vendor_ramdisk.cpio.lz4
cd ..

# pack patched image
eval set -- $(python mkbootimg/unpack_bootimg.py --boot_img vendor_boot.img --out out --format=mkbootimg | sed -E 's/--vendor_ramdisk[[:space:]]+[^[:space:]]+//g')
python mkbootimg/mkbootimg.py "$@" --vendor_ramdisk patched_vendor_ramdisk.cpio.lz4 --vendor_boot images/vendor_boot_patched.img
