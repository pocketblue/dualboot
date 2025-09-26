#!/usr/bin/env bash

set -uexo pipefail

sudo mount -o loop,ro images/root.raw /mnt
sudo tar -C /mnt -czf fedora_root.tar.gz ostree

mv images/boot.raw images/fedora_boot.raw
mv images/esp.raw  images/fedora_esp.raw

curl -L https://github.com/gmankab/sgdisk/releases/download/v1.0.10/sgdisk -o images/sgdisk
curl -L https://github.com/gmankab/parted/releases/download/v3.6/parted -o images/parted
