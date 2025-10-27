#!/usr/bin/env bash

set -uexo pipefail

# check dependencies
which 7z
which git
which curl
which cpio
which gzip
which python
which payload-dumper-go

export patch=$(readlink -f devices/nothing-spacewar/ext4_noencrypt.patch)

# unpack image
curl -L https://mirrorbits.lineageos.org/full/Spacewar/20251022/lineage-23.0-20251022-nightly-Spacewar-signed.zip -o lineage_rom.zip
7z x lineage_rom.zip -o./lineage_rom
payload-dumper-go lineage_rom/payload.bin

# patch image
mkdir vendor_patched
sudo mount extracted_*/vendor.img /mnt
sudo cp -a /mnt/. vendor_patched
sudo umount /mnt
sudo chown -R $USER vendor_patched
env --chdir=vendor_patched git apply $patch

# pack patched image
mkfs.erofs -zlz4hc,12 -C65536 -Efragments,ztailpacking images/vendor_patched.img vendor_patched
