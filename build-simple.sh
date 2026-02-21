#!/bin/bash

# Simple Swift Build Script (No CMake, No Admin Required)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build"

echo "=========================================="
echo "Building macOS-Like Operating System"
echo "=========================================="
echo ""

# Check Swift availability
if ! command -v swift &> /dev/null; then
    echo "ERROR: Swift is not installed."
    exit 1
fi

echo "[1/3] Preparing build environment..."
mkdir -p "$PROJECT_DIR/.build"

echo "[2/3] Compiling with Swift..."
cd "$PROJECT_DIR"

# Compile just the Swift sources directly
swiftc -O \
    -framework Foundation \
    -framework AppKit \
    -framework Metal \
    -framework MetalKit \
    -framework CoreGraphics \
    -framework QuartzCore \
    Sources/main.swift \
    -o .build/macOS_OS

if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed."
    exit 1
fi

echo "[3/3] Build complete!"
echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="
echo "Executable: $PROJECT_DIR/.build/macOS_OS"
echo ""
echo "To run the operating system:"
echo "  $PROJECT_DIR/.build/macOS_OS"
echo ""
