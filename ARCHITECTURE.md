// ARCHITECTURE.md - System Architecture Overview

# macOS-Like Operating System - Architecture Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Applications Layer (Swift)               │
│  ┌──────────────┬──────────────┬──────────────┐             │
│  │   Finder     │  Terminal    │   Safari     │  ...Apps    │
│  └──────────────┴──────────────┴──────────────┘             │
└─────────────────────────────────────────────────────────────┘
         ↓                    ↓                      ↓
┌─────────────────────────────────────────────────────────────┐
│           Desktop Environment / Window Manager (Swift)      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ • Application Manager                                │   │
│  │ • Window Manager                                     │   │
│  │ • Event Manager                                      │   │
│  │ • Rendering Coordinator                              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         ↓                    ↓                      ↓
┌─────────────────────────────────────────────────────────────┐
│              System UI Components (Objective-C)             │
│  ┌──────────────┬──────────────┬──────────────┐             │
│  │ Menu Bar     │     Dock     │ Status Bar   │             │
│  └──────────────┴──────────────┴──────────────┘             │
└─────────────────────────────────────────────────────────────┘
         ↓                    ↓                      ↓
┌─────────────────────────────────────────────────────────────┐
│           Graphics & Rendering Engine (C++)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ GPU Device Manager                                   │   │
│  │ Shader System                                        │   │
│  │ Render Targets                                       │   │
│  │ Effects Pipeline (Blur, Shadow, Glass)              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         ↓                    ↓                      ↓
┌─────────────────────────────────────────────────────────────┐
│       Graphics Primitives & Window Management (C)           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ • Framebuffer Management                             │   │
│  │ • 2D Drawing (Rects, Circles, Lines)                │   │
│  │ • Texture Management                                 │   │
│  │ • Window Rendering                                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         ↓                    ↓                      ↓
┌─────────────────────────────────────────────────────────────┐
│                  Kernel (C)                                  │
│  ┌────────────────────┬────────────────────┐                │
│  │ Process Manager    │ Memory Manager     │ Device Manager │
│  │ • Scheduling       │ • Allocation       │ • Hardware     │
│  │ • Context Switch   │ • Deallocation     │ • Drivers      │
│  │ • IPC              │ • Protection       │ • Abstraction  │
│  └────────────────────┴────────────────────┘                │
└─────────────────────────────────────────────────────────────┘
         ↓                    ↓                      ↓
┌─────────────────────────────────────────────────────────────┐
│              Hardware / macOS Frameworks                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ • Metal GPU                                          │   │
│  │ • AppKit                                             │   │
│  │ • Core Graphics                                      │   │
│  │ • File System                                        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. Kernel Layer (C)

**Responsibility**: Core operating system functionality

**Components**:
- **Process Management**
  - Process creation/destruction
  - Process scheduling (round-robin)
  - Process state management
  - CPU time tracking

- **Memory Management**
  - Heap allocation/deallocation
  - Memory pool management
  - Memory information tracking
  - Memory protection (basic)

- **Device Management**
  - Device enumeration
  - Device initialization
  - Device abstraction interface
  - Device state management

**Key Data Structures**:
```c
Process {
    pid,
    name,
    priority,
    state,
    cpu_time
}

MemoryInfo {
    total_memory,
    used_memory,
    free_memory
}

Device {
    device_id,
    type,
    name,
    enabled
}
```

**API Example**:
```c
kernel_init();              // Initialize kernel
process_create("app", fn);  // Create process
get_memory_info();          // Query memory
kernel_run();               // Run scheduler
```

---

### 2. Graphics & Rendering Layer (C++)

**Responsibility**: Hardware-accelerated graphics rendering

**Components**:

- **GPU Device Management**
  - Metal device initialization (macOS)
  - Command queue management
  - Device capability querying
  - Resource management

- **Shader System**
  - Shader compilation
  - Program linking
  - Uniform management
  - Shader caching

- **Render Targets**
  - Framebuffer creation
  - Color/depth attachments
  - Texture rendering
  - Off-screen rendering

- **Effects Pipeline**
  - Blur filters
  - Shadow rendering
  - Glass/transparency effects
  - Particle systems
  - Vignette effects
  - Smooth transitions

**Key Classes**:
```cpp
GPUDevice {
    initialize(),
    shutdown(),
    getDeviceName()
}

ShaderProgram {
    use(),
    setUniform()
}

AdvancedRenderer {
    enableBlur(),
    enableShadow(),
    enableGlassEffect(),
    transition*()
}

RenderTarget {
    bind(),
    unbind(),
    clear()
}
```

---

### 3. Graphics Primitives Layer (C)

**Responsibility**: Low-level 2D graphics and window rendering

**Components**:
- **Framebuffer Management**
  - Direct pixel access
  - Color space management
  - Format conversion

- **Drawing Primitives**
  - Filled rectangles
  - Rounded rectangles
  - Circles
  - Lines (Bresenham algorithm)
  - Gradients
  - Anti-aliasing

- **Texture Management**
  - Texture creation/destruction
  - Texture atlasing
  - Texture filtering
  - Sprite rendering

- **Effects**
  - Blur effects
  - Shadow effects
  - Gradient rendering

**API Example**:
```c
GraphicsContext* ctx = graphics_init(1440, 900);
Color red = {255, 255, 0, 0};
Rect rect = {100, 100, 200, 200};
draw_rounded_rect(ctx, rect, red, 10.0f);
apply_blur(ctx, rect, 5.0f);
graphics_present(ctx);
```

---

### 4. Window Management Layer (C)

**Responsibility**: Window lifecycle and rendering

**Components**:
- **Window Creation/Destruction**
  - Dynamic window allocation
  - Window property management
  - Resource cleanup

- **Window State Management**
  - Hidden/Minimized/Normal/Maximized/Fullscreen
  - Focus/blur state
  - Window ordering (z-order)

- **Window Rendering**
  - Titlebar rendering
  - Shadow effects
  - Window bounds clipping
  - Content rendering callbacks

- **Event Routing**
  - Mouse/touch events
  - Resize events
  - Close events
  - Focus events

**Data Structure**:
```c
WindowManager {
    windows[],
    window_count,
    focused_window,
    
    create_window(),
    destroy_window(),
    set_focused()
}

Window {
    window_id,
    title,
    bounds,
    state,
    flags,
    on_draw callback,
    on_resize callback,
    on_close callback
}
```

---

### 5. System UI Layer (Objective-C)

**Responsibility**: macOS-specific UI components

**Components**:
- **Menu Bar**
  - Application menus
  - Status menus
  - Custom styling

- **Dock**
  - Application icons
  - Pinned applications
  - Preview on hover (planned)
  - Badge support (planned)

- **Status Bar**
  - System clock
  - Battery indicator
  - Network status
  - Accessibility features

**Classes**:
```objective-c
MacOSLikeDock {
    - addItem()
    - removeItem()
    - drawRect()
}

MacOSLikeMenuBar {
    - drawRect()
}

SystemStatusBar {
    - updateStatus()
    - drawRect()
}
```

---

### 6. Desktop Environment & Window Manager (Swift)

**Responsibility**: Application lifecycle and coordination

**Key Managers**:

- **DesktopEnvironment** (Singleton)
  - Coordinates all subsystems
  - Manages lifecycle

- **WindowManager**
  - Multi-window management
  - Focus handling
  - Z-order management

- **ApplicationManager**
  - Application launching
  - Application termination
  - Process tracking

- **EventManager**
  - Main event loop
  - Event dispatching
  - Input handling

- **RenderEngine**
  - Frame rendering
  - Display refresh
  - Performance timing

**Architecture Pattern**:
```swift
DesktopEnvironment (Singleton)
  ├── WindowManager
  │   ├── WindowComponent[]
  ├── ApplicationManager
  │   ├── Application[]
  ├── EventManager
  │   └── Event Loop
  └── RenderEngine
      └── Render Pipeline
```

---

### 7. Applications Layer (Swift)

**Responsibility**: User applications

**Application Types**:
- Finder - File browser
- Terminal - Shell interface
- Safari - Web browser
- Mail - Email client
- Calendar - Calendar app
- System Preferences - Settings

**Base Class**:
```swift
class Application {
    func launch()
    func terminate()
    func createWindow()
}
```

All applications follow MVC pattern and inherit from Application base class.

---

## Data Flow

### Window Creation Flow
```
Application.createWindow()
  ↓
DesktopEnvironment.windowManager.createWindow()
  ↓
WindowManager.register()
  ↓
Window allocated and initialized
  ↓
Application receives Window reference
```

### Rendering Flow
```
EventManager.startEventLoop()
  ↓
Timer (60 FPS)
  ↓
processEvents()
  ↓
RenderEngine.render()
  ↓
For each visible window:
  ├─ Call window.on_draw callback
  ├─ Draw window background
  ├─ Draw titlebar (if enabled)
  ├─ Draw window shadow
  └─ Draw window contents

  ↓
Graphics context presented to display
```

### Event Flow
```
User Input (Mouse/Keyboard)
  ↓
EventManager.processInput()
  ↓
Determine which window receives event
  ↓
Call appropriate window callback:
  ├─ on_resize
  ├─ on_mouse_event
  ├─ on_key_event
  └─ on_close

  ↓
Application handles event
```

---

## Component Interactions

### Kernel ↔ Graphics
```
Process creates rendering context
  ↓
Process writes to framebuffer (shared memory)
  ↓
Graphics engine reads framebuffer
  ↓
Applies effects
  ↓
Presents to display
```

### Graphics ↔ Window Manager
```
Window manager requests window rendering
  ↓
Graphics engine draws window frame
  ↓
Graphics engine calls window's on_draw callback
  ↓
Application draws its content
  ↓
Window manager applies effects (shadow, blur)
  ↓
Graphics engine presents final result
```

### Applications ↔ Desktop Environment
```
Application.launch()
  ↓
DesktopEnvironment.applicationManager.launchApplication()
  ↓
Application instance created
  ↓
Application.createWindow() called
  ↓
Window created and registered
  ↓
Application begins event processing
```

---

## Performance Characteristics

**Display Loop**:
- Target: 60 FPS
- Frame time: 16.67ms
- Vsync enabled for smooth rendering

**Memory Usage**:
- Base: ~100-150 MB
- Per window: ~5-10 MB (depends on size)
- Per application: ~20-50 MB

**Rendering**:
- GPU accelerated (Metal on macOS)
- Software fallback available
- Batch rendering for efficiency
- Z-order optimization

---

## Extensibility Points

### Adding New Graphics Effects
1. Create shader in graphics engine
2. Implement in AdvancedRenderer
3. Call from rendering pipeline

### Adding New Application
1. Extend Application base class
2. Implement createWindow()
3. Register in ApplicationManager
4. Launch via desktop environment

### Adding New Kernel Feature
1. Implement in kernel.c
2. Export function in kernel.h
3. Call from higher layers

### Adding New System Service
1. Create service header
2. Implement service
3. Register with kernel/manager
4. Call from applications

---

## Future Enhancements

- [ ] Virtual memory system
- [ ] Process isolation (sandboxing)
- [ ] Interprocess communication (IPC)
- [ ] Hardware abstraction layer (HAL)
- [ ] Device driver framework
- [ ] Plugin system
- [ ] Networking stack
- [ ] File system abstraction
- [ ] Advanced accessibility features
- [ ] Widget system
