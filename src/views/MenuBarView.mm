#import "MenuBarView.h"

@interface MenuBarView ()
@property (nonatomic, strong) NSMutableArray *menuItemRects;
@property (nonatomic, assign) NSInteger hoveredItem;
@property (nonatomic, assign) NSRect appleLogoRect;
@property (nonatomic, assign) NSRect wifiRect;
@end

@implementation MenuBarView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.timeFormatter = [[NSDateFormatter alloc] init];
        [self.timeFormatter setDateFormat:@"EEE MMM d  h:mm a"];
        self.currentTime = [self.timeFormatter stringFromDate:[NSDate date]];
        self.activeApp = @"Finder";
        self.hoveredItem = -1;
        self.menuItemRects = [NSMutableArray array];
        
        self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateClock)
                                                         userInfo:nil
                                                          repeats:YES];
        
        // Enable mouse tracking
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                    options:(NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited)
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)updateClock {
    self.currentTime = [self.timeFormatter stringFromDate:[NSDate date]];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.menuItemRects removeAllObjects];
    
    // Translucent menu bar background (macOS style)
    [[NSColor colorWithWhite:0.98 alpha:0.85] setFill];
    NSRectFill(self.bounds);
    
    // Subtle bottom shadow line
    [[NSColor colorWithWhite:0.0 alpha:0.12] setFill];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 0.5));
    
    // Apple logo
    self.appleLogoRect = NSMakeRect(8, 0, 30, self.bounds.size.height);
    
    if (self.hoveredItem == -2) {
        [[NSColor colorWithWhite:0.0 alpha:0.08] setFill];
        [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(10, 2, 24, 20) xRadius:4 yRadius:4] fill];
    }
    
    NSDictionary *appleAttrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:16 weight:NSFontWeightRegular],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.85]
    };
    [@"" drawAtPoint:NSMakePoint(14, 4) withAttributes:appleAttrs];
    
    // App name (bold) + Menu items
    CGFloat xOffset = 42;
    
    // Active app name (bold, like real macOS)
    NSDictionary *appNameAttrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:13.5 weight:NSFontWeightBold],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.88]
    };
    NSSize appNameSize = [self.activeApp sizeWithAttributes:appNameAttrs];
    NSRect appNameRect = NSMakeRect(xOffset - 6, 0, appNameSize.width + 12, self.bounds.size.height);
    [self.menuItemRects addObject:@{@"rect": [NSValue valueWithRect:appNameRect], @"name": self.activeApp}];
    
    if (self.hoveredItem == 0) {
        [[NSColor colorWithWhite:0.0 alpha:0.08] setFill];
        [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(xOffset - 6, 2, appNameSize.width + 12, 20) xRadius:4 yRadius:4] fill];
    }
    [self.activeApp drawAtPoint:NSMakePoint(xOffset, 4) withAttributes:appNameAttrs];
    xOffset += appNameSize.width + 20;
    
    // Other menu items
    NSArray *menuItems = @[@"File", @"Edit", @"View", @"Go", @"Window", @"Help"];
    NSDictionary *menuAttrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:13.5 weight:NSFontWeightMedium],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.88]
    };
    
    for (NSInteger i = 0; i < (NSInteger)menuItems.count; i++) {
        NSString *item = menuItems[i];
        NSSize size = [item sizeWithAttributes:menuAttrs];
        NSRect itemRect = NSMakeRect(xOffset - 6, 0, size.width + 12, self.bounds.size.height);
        [self.menuItemRects addObject:@{@"rect": [NSValue valueWithRect:itemRect], @"name": item}];
        
        if (self.hoveredItem == (i + 1)) {
            [[NSColor colorWithWhite:0.0 alpha:0.08] setFill];
            [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(xOffset - 6, 2, size.width + 12, 20) xRadius:4 yRadius:4] fill];
        }
        
        [item drawAtPoint:NSMakePoint(xOffset, 4) withAttributes:menuAttrs];
        xOffset += size.width + 18;
    }
    
    // Right side status items
    NSDictionary *statusAttrs = @{
        NSFontAttributeName: [NSFont monospacedDigitSystemFontOfSize:13 weight:NSFontWeightMedium],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.85]
    };
    
    CGFloat rightX = self.bounds.size.width - 14;
    
    // Time
    NSSize timeSize = [self.currentTime sizeWithAttributes:statusAttrs];
    rightX -= timeSize.width;
    [self.currentTime drawAtPoint:NSMakePoint(rightX, 4) withAttributes:statusAttrs];
    
    // Control Center icon
    rightX -= 28;
    [@"⚙" drawAtPoint:NSMakePoint(rightX, 3) withAttributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:14],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.75]
    }];
    
    // WiFi icon (clickable)
    rightX -= 28;
    self.wifiRect = NSMakeRect(rightX - 4, 0, 32, self.bounds.size.height);
    [@"📶" drawAtPoint:NSMakePoint(rightX, 3) withAttributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:14],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.85]
    }];
    
    // Battery
    rightX -= 40;
    [@"🔋100%" drawAtPoint:NSMakePoint(rightX, 4) withAttributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:11],
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.0 alpha:0.85]
    }];
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger oldHovered = self.hoveredItem;
    self.hoveredItem = -1;
    
    // Check Apple logo
    if (NSPointInRect(location, self.appleLogoRect)) {
        self.hoveredItem = -2;
    } else {
        // Check menu items
        for (NSInteger i = 0; i < (NSInteger)self.menuItemRects.count; i++) {
            NSDictionary *itemInfo = self.menuItemRects[i];
            NSRect rect = [itemInfo[@"rect"] rectValue];
            if (NSPointInRect(location, rect)) {
                self.hoveredItem = i;
                break;
            }
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
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // Check Apple logo click
    if (NSPointInRect(location, self.appleLogoRect)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(menuBarAppleMenuClicked)]) {
            [self.delegate menuBarAppleMenuClicked];
        }
        return;
    }
    
    // Check WiFi icon click
    if (NSPointInRect(location, self.wifiRect)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(menuBarItemClicked:)]) {
            [self.delegate menuBarItemClicked:@"WiFi"];
        }
        return;
    }
    
    // Check menu item clicks
    for (NSDictionary *itemInfo in self.menuItemRects) {
        NSRect rect = [itemInfo[@"rect"] rectValue];
        if (NSPointInRect(location, rect)) {
            NSString *itemName = itemInfo[@"name"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(menuBarItemClicked:)]) {
                [self.delegate menuBarItemClicked:itemName];
            }
            break;
        }
    }
}

@end
