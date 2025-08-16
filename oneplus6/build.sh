mkdir images

curl -L https://dl.orangefox.download/635928283c05f43c193c39e2 -o ofox.zip
7z x ofox.zip -o./ofox
mv ofox/recovery.img images/ofox_enchilada.img

curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-enchilada.img -o images/uboot_enchilada.img
curl -L https://mirrorbits.lineageos.org/full/enchilada/20250813/boot.img -o images/lineage_boot.img
curl -L https://mirrorbits.lineageos.org/full/enchilada/20250813/dtbo.img -o images/lineage_dtbo.img
curl -L https://github.com/gmankab/sgdisk/releases/download/v1.0.10/sgdisk -o images/sgdisk
curl -L https://github.com/gmankab/parted/releases/download/v3.6/parted -o images/parted

curl -L https://mirrorbits.lineageos.org/full/enchilada/20250813/lineage-22.2-20250813-nightly-enchilada-signed.zip -o images/lineage_rom.zip

curl -LO https://github.com/pocketblue/pocketblue/releases/download/42.20250810/pocketblue-oneplus6-gnome-mobile-42.7z
7z x pocketblue-oneplus6-gnome-mobile-42.7z -o./pocketblue

cp pocketblue/images/boot.raw images/fedora_boot.raw
cp pocketblue/images/esp.raw images/fedora_esp.raw

mkdir root_raw
sudo mount -o ro,loop pocketblue/images/root.raw root_raw
sudo tar -C root_raw/root -cpf fedora_root.tar .
sudo chmod 666 fedora_root.tar
7z a -txz -mx=9 images/fedora_root.tar.xz fedora_root.tar

install -Dm 0755 oneplus6/dualboot.sh dualboot_oneplus6_enchilada.sh

7z a -mx9 oneplus6_dualboot.7z dualboot_oneplus6_enchilada.sh images
