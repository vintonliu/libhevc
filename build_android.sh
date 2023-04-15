#!/bin/bash

export ANDROID_NDK="/Users/wenchang.liu/Library/Android/sdk/ndk/21.4.7075529"
# echo $ANDROID_NDK
CURRENT_DIR=$(cd $(dirname $0); pwd)

android_abis=(
    "armeabi-v7a"
    "arm64-v8a"
    "x86"
    "x86_64"
)

cflags=(
    # armeabi-v7a
    "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -fstack-protector-all -fPIE -fno-tree-vectorize -DMULTICORE -DDISABLE_NEONINTR -DARM -DARMGCC -DDISABLE_NEON -DDEFAULT_ARCH=D_ARCH_ARM_NONEON"
    # arm64-v8a
    "-march=armv8-a -fstack-protector-all -fPIE -DMULTICORE -DARMV8 -DDISABLE_NEONINTR -DARM -DARMGCC -DDEFAULT_ARCH=D_ARCH_ARMV8_GENERIC"
    # x86
    "-march=i686 -fstack-protector-all -fPIE -DMULTICORE -DX86 -DDISABLE_AVX2 -msse4.2 -mno-avx -DDEFAULT_ARCH=D_ARCH_X86_SSE42"
    # x86_64
    "-march=x86-64 -fstack-protector-all -fPIE -DMULTICORE -DX86 -DDISABLE_AVX2 -msse4.2 -mno-avx -DDEFAULT_ARCH=D_ARCH_X86_SSE42"
)

asmflags=(
    "-UDISABLE_NEON -UDEFAULT_ARCH -DDEFAULT_ARCH=D_ARCH_ARM_A9Q"
    ""
    ""
    ""
)

# predefines=(
#     "-DARM  -DARMGCC -DDEFAULT_ARCH=D_ARCH_ARM_A9Q -DDISABLE_NEONINTR"
#     "-DARMV8 -DARMGCC -DARM -DDEFAULT_ARCH=D_ARCH_ARMV8_GENERIC"
# )

hosts=(
    # armeabi-v7a
    "armv7a-linux-androideabi"
    # arm64-v8a
    "aarch64-linux-android"
    # x86
    "i686-linux-android"
    # x86_64
    "x86_64-linux-android"
)

platforms=(
    19
    21
    19
    21
)

PLATFORM=23
TOOLCHAIN_PREFIX=$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin

BUILD_DIR=build/android
PRODUCT_DIR=$CURRENT_DIR/product/android
rm -rf $PRODUCT_DIR
# rm -rf $BUILD_DIR
# mkdir -p $BUILD_DIR && cd $BUILD_DIR

count=${#android_abis[@]}
for((i=0;i<count;i++)) do
    echo "building ${android_abis[i]}"
    CMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake"
    if [ "${android_abis[i]}" = "armeabi-v7a" ]; then
        CMAKE_TOOLCHAIN_FILE="$CURRENT_DIR/cmake/toolchains/aarch32_toolchain.cmake"
    fi

    echo "CMAKE_TOOLCHAIN_FILE: $CMAKE_TOOLCHAIN_FILE"
    rm -rf $BUILD_DIR/${android_abis[i]}
    mkdir -p $BUILD_DIR/${android_abis[i]} && cd $BUILD_DIR/${android_abis[i]}
    if [ "${android_abis[i]}" = "armeabi-v7a" ]; then
        CC=$TOOLCHAIN_PREFIX/${hosts[i]}${platforms[i]}-clang
        CXX=$TOOLCHAIN_PREFIX/${hosts[i]}${platforms[i]}-clang++
        echo "CC: $CC"
        echo "CXX: $CXX"        
        # -DCMAKE_TOOLCHAIN_FILE=$CURRENT_DIR/cmake/toolchains/$CMAKE_TOOLCHAIN_FILE 
        cmake $CURRENT_DIR -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE -DCMAKE_INSTALL_PREFIX=$PRODUCT_DIR/${android_abis[i]} \
            -DCMAKE_SYSTEM_NAME=Android \
            -DCMAKE_C_COMPILER=$CC \
            -DCMAKE_CXX_COMPILER=$CXX \
            -DCMAKE_C_FLAGS="${cflags[i]}" \
            -DCMAKE_ASM_FLAGS="${asmflags[i]}"
    else
        cmake $CURRENT_DIR -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE  -DCMAKE_INSTALL_PREFIX=$PRODUCT_DIR/${android_abis[i]} \
            -DANDROID_ABI=${android_abis[i]} \
            -DANDROID_PLATFORM=android-${platforms[i]} \
            -DCMAKE_C_FLAGS="${cflags[i]}" \
            -DCMAKE_ASM_FLAGS="${asmflags[i]}"
    fi

    make && make install

    cd -
done
