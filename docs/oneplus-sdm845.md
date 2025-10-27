### Install Fedora Atomic + Lineage OS dualboot on oneplus6 / oneplus6t

- **your current os and all your files will be deleted**
- you need linux computer or mac
- if your computer runs windows, you can use [wsl](https://docs.fedoraproject.org/en-US/cloud/wsl)
- you should have `adb` and `fastboot` installed on your computer
- log into your github account to be able to download images from actions
- download latest image from [actions](https://github.com/pocketblue/dualboot/actions)
- unarchive it
- boot into fastboot and connect the device to your computer via usb
- make sure bootloader is unlocked
- run `flash_*_fedora_lineage_dualboot.sh` script
- if you want boot fedora, run `fastboot --set-active=a`
- if you want boot lineage, run `fastboot --set-active=b`
