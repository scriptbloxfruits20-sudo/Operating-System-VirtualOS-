cmake_minimum_required(VERSION 3.20)
project(MacOSLikeOS VERSION 1.0.0 LANGUAGES C CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_OBJC_FLAGS "${CMAKE_OBJC_FLAGS} -fms-extensions")

# Find required packages
find_package(Threads REQUIRED)

# GLM for math
include_directories(${PROJECT_SOURCE_DIR}/external/glm)

# Core source files - C Layer (Kernel & Graphics)
set(C_SOURCES
    src/kernel/kernel.c
    src/graphics/graphics.c
    src/ui/window.c
)

# C++ sources (Advanced Graphics)
set(CXX_SOURCES
    src/graphics/GraphicsEngine.cpp
)

# Objective-C++ sources (AppKit shim)
set(OBJCXX_SOURCES
    src/OSWindowImpl.mm
)

# C++ sources (Application logic)
set(CPP_SOURCES
    src/main.mm
    src/DesktopEnvironment.cpp
    src/WindowManager.cpp
    src/Window.cpp
    src/ApplicationManager.cpp
    src/Application.cpp
    src/EventManager.cpp
    src/RenderEngine.cpp
)

# Create library for C/C++ components
add_library(os_core STATIC
    ${C_SOURCES}
    ${CXX_SOURCES}
)

target_include_directories(os_core PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)

# Link libraries
target_link_libraries(os_core PUBLIC Threads::Threads)

# macOS specific frameworks
if(APPLE)
    target_link_libraries(os_core PUBLIC
        "-framework Foundation"
        "-framework AppKit"
        "-framework Metal"
        "-framework MetalKit"
        "-framework CoreGraphics"
        "-framework QuartzCore"
    )
endif()

# Main executable
add_executable(macOS_OS
    ${C_SOURCES}
    ${CXX_SOURCES}
    ${OBJCXX_SOURCES}
    ${CPP_SOURCES}
)

target_include_directories(macOS_OS PRIVATE
    ${PROJECT_SOURCE_DIR}/include
)

target_link_libraries(macOS_OS PRIVATE
    os_core
)

if(APPLE)
    target_link_libraries(macOS_OS PRIVATE
        "-framework Foundation"
        "-framework AppKit"
        "-framework Metal"
        "-framework MetalKit"
        "-framework CoreGraphics"
    )
    
    # Set macOS deployment target
    set_target_properties(macOS_OS PROPERTIES
        MACOSX_DEPLOYMENT_TARGET "10.13"
    )
endif()

# Compiler flags for optimization
if(APPLE)
    target_compile_options(os_core PRIVATE -O3 -march=native)
    target_compile_options(macOS_OS PRIVATE -O3 -march=native)
endif()

# Enable testing
enable_testing()
