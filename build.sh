#!/bin/bash

# Build script for macOS-like Operating System

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
INSTALL_DIR="$PROJECT_DIR/install"

LOCAL_CMAKE_BIN="$HOME/Downloads/cmake-3.27.5-macos-universal/CMake.app/Contents/bin"
if [ -d "$LOCAL_CMAKE_BIN" ]; then
    export PATH="$LOCAL_CMAKE_BIN:$PATH"
fi

# If you have a locally extracted LLVM toolchain, prefer it without requiring sudo
LOCAL_LLVM_BIN="$HOME/Downloads/clang+llvm-15.0.7-x86_64-apple-darwin/bin"
if [ -d "$LOCAL_LLVM_BIN" ]; then
    export PATH="$LOCAL_LLVM_BIN:$PATH"
fi

echo "=========================================="
echo "Building macOS-Like Operating System"
echo "=========================================="
echo ""

# Check for required tools
if ! command -v cmake &> /dev/null; then
    echo "ERROR: CMake is not installed. Please install CMake 3.20 or later."
    exit 1
fi

if ! command -v swift &> /dev/null; then
    echo "ERROR: Swift is not installed. Please install Xcode Command Line Tools."
    exit 1
fi

# Create build directory
echo "[1/5] Creating build directory..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
echo "[2/5] Configuring with CMake..."
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -GXcode

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed."
    exit 1
fi

# Build the project
echo "[3/5] Building project (using all available cores)..."
CORE_COUNT=$(sysctl -n hw.ncpu)
make -j"$CORE_COUNT"

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed."
    exit 1
fi

# Create install directory
echo "[4/5] Installing..."
mkdir -p "$INSTALL_DIR"
make install

if [ $? -ne 0 ]; then
    echo "ERROR: Installation failed."
    exit 1
fi

# Print summary
echo ""
echo "[5/5] Build completed successfully!"
echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="
echo "Project Directory: $PROJECT_DIR"
echo "Build Directory:   $BUILD_DIR"
echo "Install Directory: $INSTALL_DIR"
echo ""
echo "Executable: $INSTALL_DIR/bin/macOS_OS"
echo ""
echo "To run the application:"
echo "  $BUILD_DIR/macOS_OS"
echo ""
echo "To clean build:"
echo "  rm -rf $BUILD_DIR"
echo "=========================================="
