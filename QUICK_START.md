# QUICK_START.md - Get Running in 5 Minutes

## 🚀 Quick Start Guide

### Prerequisites Check
```bash
# Check you have the required tools
xcode-select --install   # If needed, installs Xcode Command Line Tools
brew install cmake       # Install CMake if not present
swift --version          # Should be Swift 5.0+
```

---

## Step 1: Initialize Project (1 minute)

```bash
cd "/Users/Samar/Desktop/Operating System Project 2"
chmod +x init.sh build.sh quick_ref.sh
./init.sh
```

This will:
- ✓ Check system requirements
- ✓ Create necessary directories
- ✓ Download GLM math library
- ✓ Setup environment

---

## Step 2: Build Project (2-3 minutes)

```bash
./build.sh
```

Or with quick reference:
```bash
./quick_ref.sh build
```

This will:
- ✓ Create CMake build configuration
- ✓ Compile all C/C++ code
- ✓ Compile Swift code
- ✓ Link everything together
- ✓ Generate executable

**Output**: `build/macOS_OS`

---

## Step 3: Run the OS (instantly)

```bash
./build/macOS_OS
```

Or using quick reference:
```bash
./quick_ref.sh run
```

You should see initialization messages:
```
[Desktop Environment] Initializing macOS-like operating system...
[Desktop Environment] System initialized successfully
[Desktop Environment] Starting main event loop...
```

---

## 📚 Next Steps

### Read Documentation (Choose one)
```bash
# Quick overview
cat README.md

# Architecture details
cat ARCHITECTURE.md

# Development guide
cat DEVELOPMENT_GUIDE.md

# Complete project summary
cat PROJECT_SUMMARY.md
```

### Try Quick Reference Commands
```bash
./quick_ref.sh help       # See all commands
./quick_ref.sh info       # See project info
./quick_ref.sh rebuild    # Clean and rebuild
./quick_ref.sh debug      # Debug with LLDB
```

### Edit Code
Open in VS Code:
```bash
code .
```

---

## 🛠️ Common Commands

| Command | Purpose |
|---------|---------|
| `./build.sh` | Build entire project |
| `./build/macOS_OS` | Run the OS |
| `./quick_ref.sh run` | Build and run |
| `./quick_ref.sh clean` | Clean build |
| `./quick_ref.sh debug` | Debug with LLDB |
| `./quick_ref.sh format` | Format code |

---

## 📁 Project Structure (What You Got)

```
Operating System Project 2/
├── include/           # 7 header files (APIs)
├── src/
│   ├── kernel/        # Kernel implementation
│   ├── graphics/      # Graphics engine
│   ├── ui/            # Window manager & System UI
│   ├── system/        # Desktop environment
│   ├── apps/          # Applications
│   └── main.swift     # Entry point
├── build/             # Build output
├── README.md          # Overview
├── ARCHITECTURE.md    # System architecture
├── DEVELOPMENT_GUIDE.md  # Dev guide
├── CMakeLists.txt     # Build config
└── build.sh           # Build script
```

---

## 🎯 What's Included

### 8 Architectural Layers
1. ✓ **Kernel** (C) - Process & memory management
2. ✓ **Graphics Primitives** (C) - 2D drawing
3. ✓ **Graphics Engine** (C++) - Advanced rendering
4. ✓ **GPU Support** (Swift) - Metal acceleration
5. ✓ **Window Manager** (C) - Multi-window handling
6. ✓ **System UI** (Objective-C) - Menu Bar, Dock
7. ✓ **Desktop Environment** (Swift) - Coordination
8. ✓ **Applications** (Swift) - System apps

### 6 System Applications
- ✓ Finder - File browser
- ✓ Terminal - Command line
- ✓ Safari - Web browser
- ✓ Mail - Email client
- ✓ Calendar - Event scheduling
- ✓ System Preferences - Settings

### Graphics Features
- ✓ GPU acceleration (Metal)
- ✓ Smooth 60 FPS rendering
- ✓ No pixelation
- ✓ Modern visual effects:
  - Blur
  - Shadows
  - Glass effects
  - Gradients
  - Transitions

---

## 🐛 Troubleshooting

### Build fails
**Solution**: 
```bash
./quick_ref.sh clean
./build.sh
```

### Can't find CMake
**Solution**:
```bash
brew install cmake
```

### Swift errors
**Solution**:
```bash
xcode-select --install
```

### Permission denied on scripts
**Solution**:
```bash
chmod +x build.sh quick_ref.sh init.sh
```

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| README.md | Project overview |
| ARCHITECTURE.md | System design (detailed) |
| DEVELOPMENT_GUIDE.md | How to extend |
| PROJECT_SUMMARY.md | Complete reference |
| FILE_MANIFEST.md | All files listed |

---

## 💡 Tips

### Debug Mode
```c
// In include/os_config.h
#define DEBUG_MODE 1
#define LOG_LEVEL 4  // Full debug
```

### Use VS Code
```bash
code .
# Then use Ctrl+Shift+B to build
# Or Ctrl+F5 to debug
```

### Clean Rebuild
```bash
./quick_ref.sh rebuild
```

### Format Code
```bash
./quick_ref.sh format
```

---

## ✅ Verification

After running, you should see:
```
================================================
   macOS-Like Advanced Operating System
   Version 1.0.0
================================================

[Desktop Environment] Initializing macOS-like operating system...
[Kernel] Initialized - Total Memory: 8 GB
[GPU] Initialized: Apple Metal
[System] Menu Bar initialized
[System] Dock initialized
[System] Desktop initialized
[Desktop Environment] System initialized successfully
[Desktop Environment] Starting main event loop...
```

---

## 🎓 Learning Path

### Beginners
1. Read README.md
2. Build and run the project
3. Read ARCHITECTURE.md
4. Explore src/ files

### Intermediate
1. Read DEVELOPMENT_GUIDE.md
2. Create new application
3. Add graphics effect
4. Test modifications

### Advanced
1. Study kernel.c in detail
2. Optimize graphics pipeline
3. Extend Metal support
4. Implement new subsystems

---

## 📞 Need Help?

1. Check README.md for overview
2. Read DEVELOPMENT_GUIDE.md for specifics
3. Review ARCHITECTURE.md for structure
4. Look at existing code examples
5. Consult Apple macOS documentation

---

## 🎉 You're Ready!

Your advanced macOS-like operating system is now:
- ✓ Built
- ✓ Running
- ✓ Ready for development

**Next**: Read [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) to start extending!

---

**Time to Complete**: ~5 minutes
**Prerequisites**: macOS 10.13+, Xcode CLT, CMake
**Status**: Ready to use ✓
