#!/bin/bash

# Swift Package Manager Build Script
# No CMake or admin access required

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build"

echo "=========================================="
echo "Building macOS-Like Operating System"
echo "=========================================="
echo ""

# Create Sources directory structure
echo "[1/4] Setting up Swift package structure..."
mkdir -p "$PROJECT_DIR/Sources"

# Copy source files to Sources directory for SPM
echo "[2/4] Organizing source files..."
cp -r "$PROJECT_DIR/src"/* "$PROJECT_DIR/Sources/" 2>/dev/null || true

# Build with Swift Package Manager
echo "[3/4] Building with Swift Package Manager..."
cd "$PROJECT_DIR"

swift build -c release

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed."
    exit 1
fi

# Create symlink to executable in expected location
echo "[4/4] Finalizing build..."
mkdir -p "$PROJECT_DIR/build"
ln -sf "$BUILD_DIR/release/macOS-OS" "$PROJECT_DIR/build/macOS_OS" 2>/dev/null

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="
echo ""
echo "Executable: $PROJECT_DIR/build/macOS_OS"
echo ""
echo "To run:"
echo "  $PROJECT_DIR/build/macOS_OS"
echo ""
