#import "DockView.h"

@interface DockView ()
@property (nonatomic, strong) NSMutableSet *runningApps;
@end

@implementation DockView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hoveredItem = -1;
        self.runningApps = [NSMutableSet setWithObjects:@"Finder", nil];
        
        // macOS-style dock icons with colors
        self.dockItems = @[
            @{@"name": @"Finder", @"icon": @"📁", @"color": [NSColor colorWithRed:0.2 green:0.5 blue:0.95 alpha:1.0]},
            @{@"name": @"Safari", @"icon": @"🧭", @"color": [NSColor colorWithRed:0.2 green:0.6 blue:0.95 alpha:1.0]},
            @{@"name": @"Mail", @"icon": @"✉️", @"color": [NSColor colorWithRed:0.2 green:0.65 blue:0.95 alpha:1.0]},
            @{@"name": @"Messages", @"icon": @"💬", @"color": [NSColor colorWithRed:0.3 green:0.85 blue:0.4 alpha:1.0]},
            @{@"name": @"Photos", @"icon": @"🌈", @"color": [NSColor colorWithRed:0.95 green:0.4 blue:0.5 alpha:1.0]},
            @{@"name": @"Music", @"icon": @"🎵", @"color": [NSColor colorWithRed:0.95 green:0.3 blue:0.4 alpha:1.0]},
            @{@"name": @"Notes", @"icon": @"📝", @"color": [NSColor colorWithRed:0.95 green:0.85 blue:0.3 alpha:1.0]},
            @{@"name": @"Calendar", @"icon": @"📅", @"color": [NSColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]},
            @{@"name": @"Terminal", @"icon": @"⬛", @"color": [NSColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0]},
            @{@"name": @"Settings", @"icon": @"⚙️", @"color": [NSColor colorWithRed:0.6 green:0.6 blue:0.65 alpha:1.0]},
            @{@"name": @"Downloads", @"icon": @"⬇️", @"color": [NSColor colorWithRed:0.4 green:0.4 blue:0.9 alpha:1.0]},
        ];
        
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                    options:(NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited)
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // macOS-style frosted glass dock background
    NSRect dockRect = NSInsetRect(self.bounds, 3, 6);
    dockRect.origin.y += 4;
    dockRect.size.height -= 4;
    
    NSBezierPath *dockPath = [NSBezierPath bezierPathWithRoundedRect:dockRect xRadius:22 yRadius:22];
    
    // Semi-transparent background with blur effect simulation
    [[NSColor colorWithWhite:0.12 alpha:0.65] setFill];
    [dockPath fill];
    
    // Inner glow
    [[NSColor colorWithWhite:1.0 alpha:0.08] setStroke];
    NSRect innerRect = NSInsetRect(dockRect, 1, 1);
    NSBezierPath *innerPath = [NSBezierPath bezierPathWithRoundedRect:innerRect xRadius:21 yRadius:21];
    [innerPath setLineWidth:1.0];
    [innerPath stroke];
    
    // Outer border
    [[NSColor colorWithWhite:0.3 alpha:0.35] setStroke];
    [dockPath setLineWidth:0.5];
    [dockPath stroke];
    
    // Draw dock items
    CGFloat baseItemSize = 52;
    CGFloat spacing = 4;
    CGFloat totalWidth = self.dockItems.count * (baseItemSize + spacing) - spacing;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    for (NSInteger i = 0; i < (NSInteger)self.dockItems.count; i++) {
        NSDictionary *item = self.dockItems[i];
        CGFloat size = baseItemSize;
        CGFloat yOffset = 0;
        
        // Smooth magnification effect (macOS style)
        if (self.hoveredItem >= 0) {
            CGFloat distance = fabs((CGFloat)i - (CGFloat)self.hoveredItem);
            if (distance < 2.5) {
                CGFloat magnification = 1.0 + (0.45 * (1.0 - distance / 2.5));
                size = baseItemSize * magnification;
                yOffset = (size - baseItemSize) * 0.7;
            }
        }
        
        CGFloat x = startX + i * (baseItemSize + spacing) + (baseItemSize - size) / 2;
        CGFloat y = 14 + yOffset;
        
        // Icon background with app color
        NSRect iconRect = NSMakeRect(x, y, size, size);
        CGFloat cornerRadius = size * 0.22;
        NSBezierPath *iconBg = [NSBezierPath bezierPathWithRoundedRect:iconRect xRadius:cornerRadius yRadius:cornerRadius];
        
        // Gradient background matching app color
        NSColor *appColor = item[@"color"];
        NSColor *lighterColor = [appColor blendedColorWithFraction:0.3 ofColor:[NSColor whiteColor]];
        NSColor *darkerColor = [appColor blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
        
        NSGradient *iconGradient = [[NSGradient alloc] initWithStartingColor:lighterColor endingColor:darkerColor];
        [iconGradient drawInBezierPath:iconBg angle:90];
        
        // Subtle inner shadow at top for depth
        [[NSColor colorWithWhite:1.0 alpha:0.25] setStroke];
        NSRect topHighlight = NSMakeRect(x + 2, y + size - 4, size - 4, 2);
        NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:topHighlight xRadius:1 yRadius:1];
        [highlightPath setLineWidth:1];
        [highlightPath stroke];
        
        // Icon emoji
        CGFloat emojiSize = size * 0.55;
        NSDictionary *iconAttrs = @{NSFontAttributeName: [NSFont systemFontOfSize:emojiSize]};
        NSString *icon = item[@"icon"];
        NSSize iconSize = [icon sizeWithAttributes:iconAttrs];
        CGFloat emojiX = x + (size - iconSize.width) / 2;
        CGFloat emojiY = y + (size - iconSize.height) / 2;
        [icon drawAtPoint:NSMakePoint(emojiX, emojiY) withAttributes:iconAttrs];
        
        // Running indicator dot (only for running apps)
        NSString *appName = item[@"name"];
        if ([self.runningApps containsObject:appName]) {
            [[NSColor colorWithWhite:0.9 alpha:0.95] setFill];
            CGFloat dotSize = 5;
            CGFloat dotX = x + (baseItemSize + (size - baseItemSize) / 2) / 2 + baseItemSize / 4 - dotSize / 2;
            NSRect dotRect = NSMakeRect(dotX, 6, dotSize, dotSize);
            [[NSBezierPath bezierPathWithOvalInRect:dotRect] fill];
        }
    }
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat itemSize = 52;
    CGFloat spacing = 4;
    CGFloat totalWidth = self.dockItems.count * (itemSize + spacing) - spacing;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    NSInteger oldHovered = self.hoveredItem;
    self.hoveredItem = -1;
    
    for (NSInteger i = 0; i < (NSInteger)self.dockItems.count; i++) {
        CGFloat x = startX + i * (itemSize + spacing);
        if (location.x >= x && location.x < x + itemSize + spacing) {
            self.hoveredItem = i;
            break;
        }
    }
    
    if (oldHovered != self.hoveredItem) {
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseExited:(NSEvent *)event {
    self.hoveredItem = -1;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
    if (self.hoveredItem >= 0 && self.hoveredItem < (NSInteger)self.dockItems.count) {
        NSDictionary *item = self.dockItems[self.hoveredItem];
        NSString *appName = item[@"name"];
        
        // Mark app as running
        [self.runningApps addObject:appName];
        [self setNeedsDisplay:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dockItemClicked:)]) {
            [self.delegate dockItemClicked:appName];
        }
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat itemSize = 52;
    CGFloat spacing = 4;
    CGFloat totalWidth = self.dockItems.count * (itemSize + spacing) - spacing;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    NSInteger clickedItem = -1;
    for (NSInteger i = 0; i < (NSInteger)self.dockItems.count; i++) {
        CGFloat x = startX + i * (itemSize + spacing);
        if (location.x >= x && location.x < x + itemSize + spacing) {
            clickedItem = i;
            break;
        }
    }
    
    if (clickedItem >= 0 && clickedItem < (NSInteger)self.dockItems.count) {
        NSDictionary *item = self.dockItems[clickedItem];
        NSString *appName = item[@"name"];
        BOOL isRunning = [self.runningApps containsObject:appName];
        
        NSMenu *contextMenu = [[NSMenu alloc] initWithTitle:@"Dock Menu"];
        
        // App name header
        NSMenuItem *headerItem = [[NSMenuItem alloc] initWithTitle:appName action:nil keyEquivalent:@""];
        headerItem.enabled = NO;
        [contextMenu addItem:headerItem];
        [contextMenu addItem:[NSMenuItem separatorItem]];
        
        // Open/Show option
        NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:isRunning ? @"Show" : @"Open" 
                                                          action:@selector(contextMenuOpen:) 
                                                   keyEquivalent:@""];
        openItem.target = self;
        openItem.representedObject = appName;
        [contextMenu addItem:openItem];
        
        // New Window option
        NSMenuItem *newWindowItem = [[NSMenuItem alloc] initWithTitle:@"New Window" 
                                                               action:@selector(contextMenuNewWindow:) 
                                                        keyEquivalent:@""];
        newWindowItem.target = self;
        newWindowItem.representedObject = appName;
        [contextMenu addItem:newWindowItem];
        
        [contextMenu addItem:[NSMenuItem separatorItem]];
        
        // Options submenu
        NSMenuItem *optionsItem = [[NSMenuItem alloc] initWithTitle:@"Options" action:nil keyEquivalent:@""];
        NSMenu *optionsMenu = [[NSMenu alloc] initWithTitle:@"Options"];
        
        NSMenuItem *keepInDock = [[NSMenuItem alloc] initWithTitle:@"Keep in Dock" action:nil keyEquivalent:@""];
        keepInDock.state = NSControlStateValueOn;
        [optionsMenu addItem:keepInDock];
        
        NSMenuItem *openAtLogin = [[NSMenuItem alloc] initWithTitle:@"Open at Login" action:nil keyEquivalent:@""];
        [optionsMenu addItem:openAtLogin];
        
        [optionsItem setSubmenu:optionsMenu];
        [contextMenu addItem:optionsItem];
        
        [contextMenu addItem:[NSMenuItem separatorItem]];
        
        // Show in Finder
        NSMenuItem *showInFinder = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" 
                                                              action:@selector(contextMenuShowInFinder:) 
                                                       keyEquivalent:@""];
        showInFinder.target = self;
        showInFinder.representedObject = appName;
        [contextMenu addItem:showInFinder];
        
        // Quit option (only if running)
        if (isRunning) {
            [contextMenu addItem:[NSMenuItem separatorItem]];
            
            NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Quit %@", appName]
                                                              action:@selector(contextMenuQuit:) 
                                                       keyEquivalent:@""];
            quitItem.target = self;
            quitItem.representedObject = appName;
            [contextMenu addItem:quitItem];
            
            NSMenuItem *forceQuitItem = [[NSMenuItem alloc] initWithTitle:@"Force Quit" 
                                                                   action:@selector(contextMenuForceQuit:) 
                                                            keyEquivalent:@""];
            forceQuitItem.target = self;
            forceQuitItem.representedObject = appName;
            [contextMenu addItem:forceQuitItem];
        }
        
        [NSMenu popUpContextMenu:contextMenu withEvent:event forView:self];
    }
}

- (void)contextMenuOpen:(NSMenuItem *)sender {
    NSString *appName = sender.representedObject;
    [self.runningApps addObject:appName];
    [self setNeedsDisplay:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dockItemClicked:)]) {
        [self.delegate dockItemClicked:appName];
    }
}

- (void)contextMenuNewWindow:(NSMenuItem *)sender {
    NSString *appName = sender.representedObject;
    [self.runningApps addObject:appName];
    [self setNeedsDisplay:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dockItemClicked:)]) {
        [self.delegate dockItemClicked:appName];
    }
}

- (void)contextMenuShowInFinder:(NSMenuItem *)sender {
    NSString *appName = sender.representedObject;
    if (self.delegate && [self.delegate respondsToSelector:@selector(dockItemClicked:)]) {
        [self.delegate dockItemClicked:@"Finder"];
    }
}

- (void)contextMenuQuit:(NSMenuItem *)sender {
    NSString *appName = sender.representedObject;
    [self.runningApps removeObject:appName];
    [self setNeedsDisplay:YES];
}

- (void)contextMenuForceQuit:(NSMenuItem *)sender {
    NSString *appName = sender.representedObject;
    [self.runningApps removeObject:appName];
    [self setNeedsDisplay:YES];
}

@end
