#!/bin/bash

# Quick reference and common commands for the macOS-like OS project

echo "================================================"
echo "macOS-Like Operating System - Quick Reference"
echo "================================================"
echo ""

# Function to show help
show_help() {
    echo "Available commands:"
    echo ""
    echo "  ./quick_ref.sh build        - Build the project"
    echo "  ./quick_ref.sh run          - Run the built application"
    echo "  ./quick_ref.sh clean        - Clean build artifacts"
    echo "  ./quick_ref.sh debug        - Build and debug with LLDB"
    echo "  ./quick_ref.sh rebuild      - Clean and rebuild"
    echo "  ./quick_ref.sh format       - Format code (clang-format)"
    echo "  ./quick_ref.sh info         - Show project information"
    echo "  ./quick_ref.sh help         - Show this help message"
    echo ""
}

# Navigate to project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Parse command
case "$1" in
    build)
        echo "Building macOS-like OS..."
        bash build.sh
        ;;
    
    run)
        if [ -f "build/macOS_OS" ]; then
            echo "Running macOS-like OS..."
            ./build/macOS_OS
        else
            echo "Error: Binary not found. Run 'build' first."
            exit 1
        fi
        ;;
    
    clean)
        echo "Cleaning build artifacts..."
        rm -rf build/
        rm -rf install/
        echo "Clean complete"
        ;;
    
    debug)
        echo "Building with debug symbols..."
        mkdir -p build
        cd build
        cmake .. -DCMAKE_BUILD_TYPE=Debug
        make -j$(sysctl -n hw.ncpu)
        echo "Starting debugger..."
        lldb ./macOS_OS
        ;;
    
    rebuild)
        echo "Rebuilding..."
        bash quick_ref.sh clean
        bash quick_ref.sh build
        ;;
    
    format)
        echo "Formatting code..."
        find src include -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.hpp" | while read f; do
            if command -v clang-format &> /dev/null; then
                clang-format -i "$f"
                echo "Formatted: $f"
            fi
        done
        ;;
    
    info)
        echo "Project Information:"
        echo "  Name: macOS-Like Advanced Operating System"
        echo "  Version: 1.0.0"
        echo "  Location: $PROJECT_DIR"
        echo ""
        echo "Structure:"
        echo "  ├── src/          - Source files"
        echo "  ├── include/      - Header files"
        echo "  ├── build/        - Build output"
        echo "  ├── CMakeLists.txt - Build configuration"
        echo "  └── README.md     - Documentation"
        echo ""
        echo "Components:"
        echo "  • Kernel (C) - Process/memory management"
        echo "  • Graphics (C++) - GPU-accelerated rendering"
        echo "  • UI (Objective-C) - macOS integration"
        echo "  • Apps (Swift) - System applications"
        echo ""
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

echo ""
