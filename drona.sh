#!/bin/bash

: <<'notice'
 *
 * Script information:
 * Script for Android kernel building.
 *
 * Copyright (C) Shivam Jadon <jadon4639@gmail.com>
 *
notice

echo -e "$yellow***********************************************"
echo "          Cloning Sources          "
echo -e "***********************************************$nocol"
git clone --depth=1 https://github.com/shivamjadon/android_kernel_xiaomi_phoenix.git -b eleven kernel
cd kernel
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone https://github.com/shivamjadon/AnyKernel3-1 AnyKernel

echo "Done"

export CONFIG_PATH=$PWD/arch/arm64/configs/phoenix_defconfig
KERNEL_DEFCONFIG=phoenix_defconfig
ANYKERNEL_DIR=$PWD/AnyKernel/
FINAL_KERNEL_ZIP=Drona_Kernel_Phoenix_v1.0.zip
export PATH=$PWD/clang/bin:$PATH
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_COMPILER_STRING="$PWD/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
export KBUILD_BUILD_HOST=DronaKernel
export KBUILD_BUILD_USER="Dronacharya"
# Speed up build process
MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Clean Before Building
echo "**** Cleaning ****"
mkdir -p out
make O=out clean

echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
echo -e "$blue***********************************************"
echo "          BUILDING KERNEL          "
echo -e "***********************************************$nocol"
make $KERNEL_DEFCONFIG O=out
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip

echo "**** Verify Image.gz-dtb & dtbo.img ****"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb
ls $PWD/out/arch/arm64/boot/dtbo.img

# Anykernel 3 time!!
echo "**** Verifying AnyKernel3 Directory ****"
ls $ANYKERNEL_DIR
echo "**** Removing leftovers ****"
rm -rf $ANYKERNEL_DIR/Image.gz-dtb
rm -rf $ANYKERNEL_DIR/dtbo.img
rm -rf $ANYKERNEL_DIR/$FINAL_KERNEL_ZIP

echo "**** Copying Image.gz-dtb & dtbo.img ****"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/
cp $PWD/out/arch/arm64/boot/dtbo.img $ANYKERNEL_DIR/

echo "**** Time to zip up! ****"
cd $ANYKERNEL_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL_DIR/$FINAL_KERNEL_ZIP $KERNELDIR/$FINAL_KERNEL_ZIP

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue***********************************************"
echo " ____________ _____ _   _   ___   "
echo " |  _  \ ___ \  _  | \ | | / _ \  "
echo " | | | | |_/ / | | |  \| |/ /_\ \ "
echo " | | | |    /| | | | . ` ||  _  | "
echo " | |/ /| |\ \\ \_/ / |\  || | | | "
echo " |___/ \_| \_|\___/\_| \_/\_| |_/ "
echo -e "***********************************************$nocol"

echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
