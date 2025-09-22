mv images/boot.raw images/fedora_boot.raw
mv images/esp.raw  images/fedora_esp.raw
mv images/root.raw  images/fedora_root.raw

sudo mount images/fedora_boot.raw /mnt
sudo sed -i '/^options / s#ostree=/ostree/#ostree=/.stowaways/fedora/ostree/#' /mnt/loader/entries/ostree-1.conf
sudo umount /mnt

7z a -mx=9 images/fedora_root.raw.gz images/fedora_root.raw
rm images/fedora_root.raw
curl -L https://github.com/gmankab/sgdisk/releases/download/v1.0.10/sgdisk -o images/sgdisk
curl -L https://github.com/gmankab/parted/releases/download/v3.6/parted -o images/parted
