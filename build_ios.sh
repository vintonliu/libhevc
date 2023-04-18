#!/bin/bash

CURRENT_DIR=$(cd $(dirname $0); pwd)
BUILD_DIR=build/ios
GASP=`which gas-preprocessor.pl`

HEADER_INCLUDE="-I${CURRENT_DIR}/common \
                -I${CURRENT_DIR}/common/arm \
                -I${CURRENT_DIR}/common/arm64 \
                -I${CURRENT_DIR}/decoder \
                -I${CURRENT_DIR}/decoder/arm64 \
                -I${CURRENT_DIR}/encoder/arm \
                -I${CURRENT_DIR}/encoder"

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR && cd $BUILD_DIR
cmake $CURRENT_DIR -DCMAKE_TOOLCHAIN_FILE=$CURRENT_DIR/cmake/toolchains/ios.toolchain.cmake \
    -DPLATFORM=OS64 \
    -DENABLE_BITCODE=FALSE \
    -DDEPLOYMENT_TARGET=10 \
    -DCMAKE_C_FLAGS="-DMULTICORE -DARMV8 -DDISABLE_NEONINTR -DARM -DARMGCC -DDEFAULT_ARCH=D_ARCH_ARMV8_GENERIC $HEADER_INCLUDE" \
    -DCMAKE_ASM_COMPILER="$GASP" \
    -DCMAKE_ASM_FLAGS="-DMULTICORE $HEADER_INCLUDE"

make libhevcdec
#cmake --build . --config Release --target libhevcdec

# -DDISABLE_NEONINTR -DARM -DARMGCC -DDEFAULT_ARCH=D_ARCH_ARMV8_GENERIC