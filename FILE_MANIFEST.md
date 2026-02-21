# File Manifest - macOS-Like Operating System

## Complete File Listing

### Documentation Files (4)
- [README.md](README.md) - Project overview, features, and quick start
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Comprehensive development guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed system architecture
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Complete project summary

### Build & Configuration (4)
- [CMakeLists.txt](CMakeLists.txt) - CMake build configuration
- [build.sh](build.sh) - Automated build script
- [quick_ref.sh](quick_ref.sh) - Quick reference commands
- [init.sh](init.sh) - Project initialization script

### Configuration & Metadata (4)
- [project.json](project.json) - Project metadata
- [MacOSLikeOS-Bridging-Header.h](MacOSLikeOS-Bridging-Header.h) - Objective-C/Swift bridge
- [.vscode/settings.json](.vscode/settings.json) - VS Code editor settings
- [.vscode/tasks.json](.vscode/tasks.json) - VS Code build tasks
- [.vscode/launch.json](.vscode/launch.json) - VS Code debug configuration

### Header Files (7)
**include/ directory:**
- [include/kernel.h](include/kernel.h) - Kernel API definitions
- [include/graphics.h](include/graphics.h) - Graphics primitives API
- [include/window.h](include/window.h) - Window management API
- [include/GraphicsEngine.hpp](include/GraphicsEngine.hpp) - Advanced C++ graphics
- [include/metal_support.h](include/metal_support.h) - Metal GPU support
- [include/utils.h](include/utils.h) - Utility functions and data structures
- [include/os_config.h](include/os_config.h) - System configuration

### Kernel Implementation (1)
**src/kernel/ directory:**
- [src/kernel/kernel.c](src/kernel/kernel.c) - Kernel implementation

### Graphics Implementation (3)
**src/graphics/ directory:**
- [src/graphics/graphics.c](src/graphics/graphics.c) - Graphics primitives
- [src/graphics/GraphicsEngine.cpp](src/graphics/GraphicsEngine.cpp) - Advanced graphics (C++)
- [src/graphics/MetalRenderer.swift](src/graphics/MetalRenderer.swift) - GPU/Metal support (Swift)

### UI Implementation (2)
**src/ui/ directory:**
- [src/ui/window.c](src/ui/window.c) - Window manager implementation
- [src/ui/SystemUI.m](src/ui/SystemUI.m) - macOS UI components (Objective-C)

### System Implementation (2)
**src/system/ directory:**
- [src/system/DesktopEnvironment.swift](src/system/DesktopEnvironment.swift) - Main desktop manager
- [src/system/utils.c](src/system/utils.c) - System utilities

### Application Implementation (1)
**src/apps/ directory:**
- [src/apps/Applications.swift](src/apps/Applications.swift) - System applications

### Main Entry Point (1)
**src/ directory:**
- [src/main.swift](src/main.swift) - Application entry point

---

## File Statistics

**Total Files**: 30+

### By Category
- **Documentation**: 4 files
- **Build Configuration**: 4 files  
- **Headers**: 7 files
- **C Implementation**: 4 files (Kernel, Graphics, Window, Utilities)
- **C++ Implementation**: 1 file (Graphics Engine)
- **Objective-C Implementation**: 1 file (System UI)
- **Swift Implementation**: 4 files (Main, Desktop, Applications, Metal)
- **Configuration**: 5 files (VS Code, Project metadata)

### By Language
- **Swift**: 4 files (~500 lines) - High-level application logic
- **C**: 4 files (~600 lines) - Core kernel and graphics
- **C++**: 1 file (~300 lines) - Advanced graphics
- **Objective-C**: 1 file (~200 lines) - macOS integration
- **CMake**: 1 file - Build system
- **Shell Scripts**: 3 files - Build automation
- **Markdown**: 4 files - Documentation
- **JSON**: 3 files - Configuration

---

## Code Statistics

### Lines of Code (Approximate)
- **Swift**: 500+ lines
- **C**: 600+ lines
- **C++**: 300+ lines
- **Objective-C**: 200+ lines
- **CMake**: 60+ lines
- **Shell Scripts**: 150+ lines
- **Total Code**: 2000+ lines

### Architecture
- **Layers**: 8 architectural layers
- **Classes/Structs**: 40+ defined types
- **Functions/Methods**: 100+ functions

---

## Key Components

### 1. Kernel Layer
- `kernel.h/c` - Process management, memory management, scheduling

### 2. Graphics Primitives
- `graphics.h/c` - 2D drawing, textures, basic effects

### 3. Graphics Engine
- `GraphicsEngine.hpp/cpp` - Advanced rendering, shaders, effects

### 4. GPU Acceleration
- `metal_support.h` - Metal framework integration
- `MetalRenderer.swift` - GPU texture management, hardware acceleration

### 5. Window Management
- `window.h/c` - Multi-window management, rendering, focus handling

### 6. System UI
- `SystemUI.m` - Menu Bar, Dock, Status Bar

### 7. Desktop Environment
- `DesktopEnvironment.swift` - Application coordination, event loop

### 8. Applications
- `Applications.swift` - Finder, Terminal, Safari, Mail, Calendar, System Preferences

---

## Build Targets

### Executables
- `macOS_OS` - Main application executable

### Libraries
- `os_core` - Static library of C/C++ components

---

## Dependencies

### External
- **GLM** (Header-only math library)

### System Frameworks (macOS)
- Foundation
- AppKit
- Metal
- MetalKit
- CoreGraphics
- QuartzCore

### Standard Libraries
- C Standard Library
- C++ Standard Library
- POSIX APIs

---

## Usage Scenarios

### Building
```bash
./build.sh              # Full build
make -C build rebuild   # Using make directly
cmake --build build     # Using CMake directly
```

### Running
```bash
./build/macOS_OS        # Run executable
./quick_ref.sh run      # Using quick reference
```

### Debugging
```bash
./quick_ref.sh debug    # Build and debug
lldb ./build/macOS_OS   # Direct LLDB
```

### Development
```bash
./init.sh               # Initialize project
./quick_ref.sh format   # Format code
./quick_ref.sh rebuild  # Clean and rebuild
```

---

## File Organization Principles

1. **Separation of Concerns**: Each component in its own layer
2. **Language Layering**: Low-level in C, high-level in Swift
3. **Interface-Implementation Split**: Headers separate from implementations
4. **Documentation Colocation**: Docs alongside code
5. **Build Configuration Centralization**: CMake for all builds

---

## Modification Points

### To Add New Application
1. Create new class in `src/apps/Applications.swift`
2. Register in `ApplicationManager`

### To Add Graphics Effect
1. Add header in `include/GraphicsEngine.hpp`
2. Implement in `src/graphics/GraphicsEngine.cpp`
3. Call from rendering pipeline

### To Extend Kernel
1. Add function to `include/kernel.h`
2. Implement in `src/kernel/kernel.c`
3. Document in DEVELOPMENT_GUIDE.md

### To Customize UI
1. Modify `src/ui/SystemUI.m`
2. Or use `DesktopEnvironment.swift`

---

## Version History

**Version 1.0.0** (February 2026)
- Foundation complete
- 8 architectural layers
- 6 system applications
- GPU acceleration support
- Full documentation

---

## Related Documentation

- [README.md](README.md) - Quick start and features
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - How to extend
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Complete overview

---

**Last Updated**: February 14, 2026
**Total Project Files**: 30+
**Status**: Foundation Complete ✓
