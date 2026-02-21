#!/bin/bash

# Manual Build Script for modular macOS-Like OS
# Bypasses CMake requirement

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
INCLUDE_DIR="$PROJECT_DIR/include"

echo "=========================================="
echo "Modular Build: macOS-Like Operating System"
echo "=========================================="

# Architecture Detection and Optimization
ARCH=$(uname -m)
OS_VER=$(sw_vers -productVersion)
echo "Architecture: $ARCH"
echo "macOS Version: $OS_VER"

if [ "$ARCH" = "arm64" ]; then
    # Apple Silicon Optimizations
    CFLAGS="-O3 -mcpu=apple-m1 -target arm64-apple-macosx11.0 -DGLM_FORCE_SIMD_NEON -DGLM_FORCE_INLINE"
    SWIFTFLAGS="-O -target arm64-apple-macosx11.0"
else
    # Intel Optimizations
    CFLAGS="-O3 -march=native -DGLM_FORCE_SIMD_SSE2 -DGLM_FORCE_INLINE"
    SWIFTFLAGS="-O"
fi

# Add Link Time Optimization (LTO) for extra performance
CFLAGS="$CFLAGS -flto"

mkdir -p "$BUILD_DIR"

# 1. Compile C Layer
echo "[1/4] Compiling C layer..."
clang $CFLAGS -c src/kernel/kernel.c -o "$BUILD_DIR/kernel.o" -I"$INCLUDE_DIR"
clang $CFLAGS -c src/graphics/graphics.c -o "$BUILD_DIR/graphics.o" -I"$INCLUDE_DIR"
clang $CFLAGS -c src/ui/window.c -o "$BUILD_DIR/window.o" -I"$INCLUDE_DIR"

# 2. Compile C++ Layer
echo "[2/4] Compiling C++ layer..."
clang++ $CFLAGS -c src/graphics/GraphicsEngine.cpp -o "$BUILD_DIR/GraphicsEngine.o" -I"$INCLUDE_DIR" -I"$PROJECT_DIR/external/glm" -std=c++17

# 3. Compile Objective-C Layer
echo "[3/4] Compiling Objective-C layer..."
clang $CFLAGS -c src/ui/SystemUI.m -o "$BUILD_DIR/SystemUI.o" -I"$INCLUDE_DIR" -fobjc-arc -framework AppKit -framework Foundation

# 4. Compile Swift Layer and Link
echo "[4/4] Compiling Swift layer and linking..."
swiftc \
    $SWIFTFLAGS \
    -import-objc-header "$PROJECT_DIR/MacOSLikeOS-Bridging-Header.h" \
    -I "$INCLUDE_DIR" \
    src/AppEntryPoint.swift \
    src/system/DesktopEnvironment.swift \
    src/apps/Applications.swift \
    src/graphics/MetalRenderer.swift \
    "$BUILD_DIR/kernel.o" \
    "$BUILD_DIR/graphics.o" \
    "$BUILD_DIR/window.o" \
    "$BUILD_DIR/GraphicsEngine.o" \
    "$BUILD_DIR/SystemUI.o" \
    -framework Foundation \
    -framework AppKit \
    -framework Metal \
    -framework MetalKit \
    -framework CoreGraphics \
    -framework QuartzCore \
    -o "$BUILD_DIR/macOS_OS"

if [ $? -eq 0 ]; then
    echo ""
    echo "SUCCESS: Build completed!"
    echo "Run with: $BUILD_DIR/macOS_OS"
else
    echo ""
    echo "ERROR: Build failed."
    exit 1
fi
