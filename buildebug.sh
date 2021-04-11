#!/bin/bash

# Resources
THREAD="-j$(nproc --all)"

export CLANG_PATH=/home/nakixii/toolchain/bin/
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=/home/nakixii/toolchain/bin/aarch64-linux-gnu- CC=clang CXX=clang++
export CROSS_COMPILE_COMPAT=/home/nakixii/toolchain/arm-eabi-gcc/bin/arm-eabi-

DEFCONFIG="venus_defconfig"

# Paths
KERNEL_DIR=`pwd`
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot/"

# Vars
export LOCALVERSION=-debug
export ARCH=arm64
export SUBARCH=$ARCH
export KBUILD_BUILD_USER=nakixii

DATE_START=$(date +"%s")

echo
echo "-------------------"
echo "Making Kernel:"
echo "-------------------"
echo

make CC="ccache clang" CXX="ccache clang++" LD=ld.lld O=out $DEFCONFIG
make CC="ccache clang" CXX="ccache clang++" LD=ld.lld O=out $THREAD 2>&1 | tee kernel.log

echo
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
ls -a $ZIMAGE_DIR
