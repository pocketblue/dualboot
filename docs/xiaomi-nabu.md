# Xiaomi Pad 5 (UEFI)

## Preparing

First, you should prepare:
- [Dualboot Installer ZIP](https://github.com/pocketblue/dualboot/releases)
- The Android ROM or Stock you want.
- [Pocketblue image you want.](https://github.com/pocketblue/pocketblue/releases)
- [TWRP](https://github.com/ArKT-7/nabu-files/raw/refs/heads/main/recovery/mod-linux-twrp.img)
- [DBKP-Installer](https://github.com/rodriguezst/nabu-dualboot-img/releases/download/20250422/installer_bootmanager_NOSB.zip)

***Do not forget backup your data!!!***

## Installing

1. ***Backup your data.***
2. Reboot into bootloader, and boot recovery with `fastboot boot mod-linux-twrp.img`
> If recovery boot stuck at black screen, try to boot again or flash `dtbo` partition with `dtbo.img` from ROM or Stock Android.

3. In recovery, press on the Penguin at top-left corner of the screen, and press **"Restore part..."** button to restore previous partition table if it was modified. Then press on the **"Partitioing"** to split your `userdata` partition for Pocketblue and Android.
> You will be asked for new `linux` partition size. It's recommended to specify half of available size.

4. Flash your Android ROM or Stock. Also root if necessary before next step.
5. Boot into recovery (step 2) and flash **DBKP-Installer** (installer\_bootmanager\_NOSB.zip).
6. Reboot to bootloader and flash Pocketblue using following commands:
```
fastboot flash linux images/fedora_rootfs.raw
fastboot flash cust  images/fedora_boot.raw
fastboot flash esp   images/fedora_esp.raw
```
7. Then reboot to bootloader again and boot recovery (step 2). Flash **Dualboot Installer ZIP** (dualboot-installer.zip).
> [!WARNING]
> If your tab stuck at rebooting, **do not force reboot it!** Just wait 5-10 mins and tablet will reboot itself (...or force reboot after 5-10 mins if still stuck).

8. Fin! Enjoy your dualboot installation! <3
> [!NOTE]
> To move between options use **Vol+ & Vol-** buttons, **Power** button to select option.
