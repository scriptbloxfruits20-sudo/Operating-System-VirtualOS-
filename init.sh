#!/bin/bash

# Project initialization script
# Sets up environment and dependencies

echo "=========================================="
echo "macOS-Like OS - Project Initialization"
echo "=========================================="
echo ""

# Check macOS
if [[ ! "$OSTYPE" == "darwin"* ]]; then
    echo "ERROR: This project is designed for macOS."
    exit 1
fi

echo "[1/5] Checking system requirements..."

# Check CMake
if ! command -v cmake &> /dev/null; then
    echo "  • CMake: NOT FOUND"
    echo "    Install with: brew install cmake"
else
    echo "  ✓ CMake: $(cmake --version | head -1)"
fi

# Check Xcode Command Line Tools
if ! command -v clang &> /dev/null; then
    echo "  • Xcode CLT: NOT FOUND"
    echo "    Install with: xcode-select --install"
else
    echo "  ✓ Xcode CLT: Installed"
fi

# Check Swift
if ! command -v swift &> /dev/null; then
    echo "  • Swift: NOT FOUND"
    echo "    Install with: Xcode Command Line Tools"
else
    echo "  ✓ Swift: $(swift --version | grep -oE 'Swift.*' | head -1)"
fi

echo ""
echo "[2/5] Creating project directories..."

# Create necessary directories
mkdir -p build
mkdir -p install
mkdir -p external/glm

echo "  ✓ Directories created"

echo ""
echo "[3/5] Downloading GLM (Math Library)..."

# Download GLM if not present
if [ ! -f "external/glm/glm.hpp" ]; then
    cd external
    
    # Try downloading GLM
    if command -v curl &> /dev/null; then
        echo "  Downloading GLM..."
        mkdir -p glm
        curl -L https://github.com/g-truc/glm/releases/download/0.9.9.8/glm-0.9.9.8.zip -o glm.zip 2>/dev/null
        
        if [ -f "glm.zip" ]; then
            unzip -q glm.zip
            mv glm/* glm/
            rm -rf glm.zip __MACOSX
            echo "  ✓ GLM installed"
        fi
    fi
    
    cd ..
else
    echo "  ✓ GLM already present"
fi

echo ""
echo "[4/5] Setting up environment..."

# Make scripts executable
chmod +x build.sh 2>/dev/null
chmod +x quick_ref.sh 2>/dev/null

echo "  ✓ Scripts made executable"

echo ""
echo "[5/5] Project initialized!"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Build the project:"
echo "   ./build.sh"
echo ""
echo "2. Run the OS:"
echo "   ./build/macOS_OS"
echo ""
echo "3. Read documentation:"
echo "   • README.md - Project overview"
echo "   • DEVELOPMENT_GUIDE.md - Detailed development guide"
echo ""
echo "4. Use quick reference:"
echo "   ./quick_ref.sh help"
echo ""
echo "=========================================="
