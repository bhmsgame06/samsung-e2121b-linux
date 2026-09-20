# Linux port for Samsung GT-E2121B

## How to run

Just download precompiled .cla firmware file and simply flash it to the phone
using [my Samsung Swift flasher](https://github.com/bhmsgame06/sflasher) or
proprietary [PNX49xx Downloader v0.3 Lite For GT-E2370](https://mega.nz/folder/2aoVnJJJ#ovZJG4cbvIOqLVEJBHrQSQ/folder/2apUFSjS),
these flashers are fully compatible with GT-E2121B. After flashing you can do
power on, use `screen` or PuTTY on 115200 baud to see the logs and shell.

## How to build

### Building the bootloader (SPL)

Just run this command in your terminal:

```bash
./build-spl.sh
```

`spl.bin` will appear.

### Building the kernel

```bash
git clone --depth=1 https://github.com/bhmsgame06/linux-pnx49xx
cd linux-pnx49xx

git checkout linux-pnx49xx

cp ../samsung-e2121b-linux/kernel.config ./.config
cp -r ../samsung-e2121b-linux/initramfs ./usr/initramfs

fakeroot make ARCH=arm CROSS_COMPILE=arm-none-eabi- -j$(nproc) xipImage dtbs
```

You can edit the kernel config if you want to do so.

### Building .cla image

In *this* current repo, do:

```bash
gcc -o build-cla build-cla.c
./build-cla spl.bin \
    linux-pnx49xx/arch/arm/boot/dts/nxp/pnx/pnx4852-samsung-gt-e2121b.dtb \
    linux-pnx49xx/arch/arm/boot/xipImage > image.cla
```

Then you'll get `image.cla` file.

*NOTE: The pre-built image contains a patched .dtb file in which the `reg`
property in the `flash` node points to address `0x91000000` instead of
`0x90000000`. This decision was taken to prevent the XIP kernel from total
freezing on the detection of the flash chip.*

## Join us

Join the ROMphonix Club community on Discord: https://discord.gg/83qJNqt48c
