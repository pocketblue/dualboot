#!/usr/bin/env bash

set -uexo pipefail

sudo mount -o loop,ro images/fedora_rootfs.raw /mnt
sudo tar -C /mnt -czf images/fedora_rootfs.tar.gz ostree
sudo umount /mnt
rm images/fedora_rootfs.raw
