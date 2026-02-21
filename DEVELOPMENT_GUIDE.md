# DEVELOPMENT_GUIDE.md

## Advanced macOS-Like Operating System - Development Guide

### Quick Start

1. **Clone and Navigate**
```bash
cd "/Users/Samar/Desktop/Operating System Project 2"
```

2. **Build the Project**
```bash
chmod +x build.sh
./build.sh
```

3. **Run the System**
```bash
./build/macOS_OS
```

---

## Project Structure Deep Dive

### Kernel Layer (`src/kernel/`)
The kernel manages core OS operations:
- **Process Management**: Creating, destroying, scheduling processes
- **Memory Management**: Tracking allocated and free memory
- **Device Abstraction**: Interfacing with hardware devices
- **Interrupt Handling**: Managing system interrupts (stub for now)

**Key Files**:
- `kernel.h` - Kernel API definitions
- `kernel.c` - Kernel implementation

**Usage Example**:
```c
uint32_t pid = process_create("MyApp", my_entry_point);
MemoryInfo* mem = get_memory_info();
```

### Graphics Layer (`src/graphics/`)
Advanced GPU-accelerated rendering system:

#### Low-Level Graphics (`graphics.c`)
- 2D drawing primitives (rectangles, circles, lines)
- Texture management
- Effects (blur, shadows, gradients)
- Framebuffer operations

**Usage Example**:
```c
GraphicsContext* ctx = graphics_init(1440, 900);
Rect bounds = {100, 100, 200, 200};
Color red = {255, 255, 0, 0};
draw_rounded_rect(ctx, bounds, red, 10.0f);
apply_blur(ctx, bounds, 5.0f);
graphics_present(ctx);
```

#### Advanced Graphics (`GraphicsEngine.cpp`)
- GPU device management (Metal on macOS)
- Shader compilation and management
- Render targets (framebuffers)
- Advanced effects:
  - Glass morphism
  - Advanced blur algorithms
  - Smooth shadows with depth
  - Particle systems
  - Vignette effects
  - Transition animations

**Usage Example**:
```cpp
GPUDevice gpu;
gpu.initialize();

AdvancedRenderer renderer;
renderer.enableGlassEffect(0.8f, 10.0f);
renderer.enableShadow({0, 0, 100}, 0.5f);
renderer.transitionFade(0.3f); // 300ms fade
```

### UI Layer (`src/ui/`)

#### Window Management (`window.c`)
Manages all application windows:
- Window creation/destruction
- Window state (minimized, maximized, normal)
- Focus management
- Event routing
- Window rendering with titlebar and effects

**Usage Example**:
```c
WindowManager* wm = window_manager_create(128);
Window* win = window_create(wm, "My App", 
    {100, 100, 800, 600}, 
    WINDOW_FLAG_TITLED | WINDOW_FLAG_RESIZABLE);
window_focus(wm, win);
```

#### System UI Components (`SystemUI.m`)
Objective-C integration with macOS:
- **MacOSLikeDock**: Application dock with smooth animations
- **MacOSLikeMenuBar**: Top menu bar with system menus
- **SystemStatusBar**: Status bar with time and battery

**Usage Example**:
```objective-c
MacOSLikeDock* dock = [[MacOSLikeDock alloc] initWithFrame:frameRect];
DockItem* item = malloc(sizeof(DockItem));
item->app_name = @"Safari";
[dock addItem:item];
```

### Desktop Environment (`src/system/`)

#### Swift Application Framework
Main application architecture and management:

**DesktopEnvironment.swift**:
- Singleton managing entire desktop
- Window management
- Application lifecycle
- Event processing
- Rendering coordination

**Built-in Applications**:
All applications inherit from `Application` class:

1. **FinderApp** - File browser
   - Directory navigation
   - File operations
   - Favorites/Recent files

2. **TerminalApp** - Command line
   - Command execution
   - Shell integration
   - Command history

3. **SafariApp** - Web browser
   - URL navigation
   - Tab management
   - Bookmarks

4. **MailApp** - Email client
   - Email management
   - Compose/reply
   - Mailbox organization

5. **CalendarApp** - Calendar
   - Event management
   - Multiple calendars
   - Event reminders

6. **SystemPreferencesApp** - Settings
   - System configuration
   - Preference panes
   - User defaults

---

## Adding New Features

### Creating a New Application

1. **Create Swift file** in `src/apps/`:
```swift
class MyApp: Application {
    init() {
        super.init(name: "My Application")
    }
    
    override func createWindow() {
        let frame = NSRect(x: 100, y: 100, width: 800, height: 600)
        window = DesktopEnvironment.shared.windowManager.createWindow(
            title: "My Application",
            frame: frame,
            style: [.titled, .closable, .miniaturizable, .resizable]
        )
    }
}
```

2. **Register in ApplicationManager**:
Edit `DesktopEnvironment.swift`:
```swift
case "MyApp":
    return MyApp()
```

3. **Launch Application**:
```swift
DesktopEnvironment.shared.applicationManager.launchApplication("MyApp")
```

### Creating Graphics Effects

1. **Add effect shader** in `GraphicsEngine.hpp`
2. **Implement in** `GraphicsEngine.cpp`
3. **Call from rendering pipeline**:
```cpp
renderer.enableCustomEffect(params);
```

### Adding System Services

1. **Create service header** in `include/`
2. **Implement in** `src/system/`
3. **Register with kernel**:
```c
kernel_register_service(SERVICE_ID, service_ptr);
```

---

## Compilation Details

### Build Flags
- **Optimization**: `-O3 -march=native` (Release)
- **Standards**: C11, C++17, Objective-C
- **Frameworks** (macOS):
  - Foundation
  - AppKit
  - Metal
  - MetalKit
  - CoreGraphics
  - QuartzCore

### Build Process
1. CMake configures project
2. C files compiled with clang
3. C++ files compiled with clang++
4. Objective-C files compiled with clang
5. Swift files compiled with swiftc
6. All linked into single executable

---

## Performance Optimization Tips

### Graphics
```cpp
// Enable hardware acceleration
gpu.initialize(); // Uses Metal on macOS

// Batch rendering operations
renderer.beginBatch();
// ... render multiple items ...
renderer.endBatch();

// Use render targets for off-screen rendering
RenderTarget target(800, 600);
target.bind();
// ... render to target ...
target.unbind();
```

### Memory
```c
// Use memory pools for frequent allocations
MemoryPool* pool = pool_create(1024, 1000);
void* ptr = pool_allocate(pool);
pool_free(pool, ptr);
pool_destroy(pool);

// Use vector for dynamic arrays
Vector* vec = vector_create(10);
vector_push(vec, element);
```

### Event Processing
```swift
// Efficient event loop
Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
    // Process 60 FPS (~16.67ms per frame)
    DesktopEnvironment.shared.renderEngine.render()
}
```

---

## Debugging

### Enable Debug Mode
Set in `include/os_config.h`:
```c
#define DEBUG_MODE 1
#define LOG_LEVEL 4 // Full debug logging
```

### Use Logging
```c
LOG_ERROR("Error message: %s", error_str);
LOG_INFO("Frame rendered: %d ms", elapsed_time);
```

### Debug with LLDB
```bash
lldb ./build/macOS_OS
(lldb) breakpoint set --file graphics.c --line 42
(lldb) run
```

---

## Architecture Patterns

### MVC Pattern (Applications)
```
Model (Data) → ViewController → View (UI)
```

### Manager Pattern (Core Systems)
```
Manager (Singleton) → Components → Resources
```

### Factory Pattern (Application Creation)
```
ApplicationManager.createApplication(name) → Application
```

### Observer Pattern (Events)
```
EventManager → EventListeners → Callbacks
```

---

## Testing

Create test files in `tests/`:
```c
void test_graphics_rendering() {
    GraphicsContext* ctx = graphics_init(640, 480);
    
    Rect rect = {0, 0, 100, 100};
    Color blue = {255, 0, 0, 255};
    draw_rect(ctx, rect, blue);
    
    // Assertions here
    
    graphics_shutdown();
}
```

---

## Extending the Kernel

### Add New System Call
1. Add to `kernel.h`:
```c
void kernel_custom_operation(int param);
```

2. Implement in `kernel.c`:
```c
void kernel_custom_operation(int param) {
    // Implementation
}
```

3. Register with scheduler if needed

### Add New Process Type
```c
typedef struct {
    Process base;
    void* custom_data;
} CustomProcess;
```

---

## Resources

- **macOS App Development**: Apple AppKit documentation
- **Graphics Programming**: Metal and Core Graphics guides
- **Swift**: swift.org documentation
- **CMake**: cmake.org documentation
- **C/C++ Best Practices**: ISO C and C++ standards

---

## Common Issues

**Issue**: Build fails with Metal not found
**Solution**: Install Xcode Command Line Tools:
```bash
xcode-select --install
```

**Issue**: Swift compilation errors
**Solution**: Check Swift version matches project requirements:
```bash
swift --version
```

**Issue**: Window not appearing
**Solution**: Ensure Desktop Environment is initialized and running main event loop.

---

## Contributing

When adding new features:
1. Follow existing code style
2. Add documentation
3. Test thoroughly
4. Update README if adding new components
5. Keep architecture modular

---

## Future Enhancements

- [ ] Implement actual Metal rendering backend
- [ ] Add networking stack
- [ ] Create file system abstraction
- [ ] Implement real process isolation
- [ ] Add hardware abstraction layer (HAL)
- [ ] Create device driver framework
- [ ] Implement virtual memory system
- [ ] Add interprocess communication (IPC)
- [ ] Create plugin system
- [ ] Add accessibility features
