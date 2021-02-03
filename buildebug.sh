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

cd $KERNEL_DIR
if grep -q "error: " kernel.log
then
	echo; echo; grep -n "error: " kernel.log; echo "\n\n"
	chown -R nakixii *
	chgrp -R nakixii *
	exit 0
elif grep -q "undefined reference to" kernel.log
then
	echo; echo; grep -n "undefined reference to" kernel.log; echo "\n\n"
	chown -R nakixii *
	chgrp -R nakixii *
	exit 0
elif grep -q "undefined symbol" kernel.log
then
	echo; echo; grep -n "undefined symbol" kernel.log; echo "\n\n"
	chown -R nakixii *
	chgrp -R nakixii *
	exit 0
elif grep -q "Error 2" kernel.log
then
	exit 0
else
TIME="$(date "+%Y%m%d-%H%M%S")"
mkdir -p tmp
cp -fp $ZIMAGE_DIR/Image tmp
cp -rp ./anykernel/* tmp
cd tmp
7za a -mx9 tmp.zip *
cp $KERNEL_DIR/prebuilts/ramdisk.img .
python mkbootimg.py \
    --header_version 3 \
    --os_version 11.0.0 \
    --os_patch_level 2021-02-00 \
    --ramdisk ramdisk.img \
    --kernel Image \
    --kernel_offset 0x8000 \
    --ramdisk_offset 0x1000000 \
    --tags_offset 0x100 \
    --pagesize 4096 \
    --output kernel.img
cd ..
rm DynamIQ*.zip
rm kernel-*.img
cp -fp tmp/tmp.zip DynamIQ-Kernel-Mi11-$TIME.zip
cp -fp tmp/kernel.img kernel-$TIME.img
rm -rf tmp
chown -R nakixii *
chgrp -R nakixii *
fi
