#!/usr/bin/env bash

echo "Cloning dependencies"

git clone --depth=1 https://github.com/shivamjadon/Drona_Kernel_Phoenix.git -b eleven kernel
cd kernel
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone https://github.com/shivamjadon/AnyKernel3-1 AnyKernel

echo "Done"

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
CLANG_VERSION=$(clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export CONFIG_PATH=$PWD/arch/arm64/configs/phoenix_defconfig
export PATH=$PWD/clang/bin:$PATH

export ARCH=arm64
export KBUILD_BUILD_HOST=DronaKernel
export KBUILD_BUILD_USER="Dronacharya"

# Compiling build
export ARCH=arm64

function compile() {
   make O=out ARCH=arm64 phoenix_defconfig
       make -j$(nproc --all) O=out \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip

if [ `ls "$IMAGE" 2>/dev/null | wc -l` != "0" ]
then
   cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
else
   finerr
fi
}
# Zipping

function zipping() {
    cd AnyKernel || exit 1
    zip -r9 DronaKernel-phoenix-${TANGGAL}.zip *
    cd ..
}
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
