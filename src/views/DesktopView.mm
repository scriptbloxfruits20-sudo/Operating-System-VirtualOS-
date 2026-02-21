#import "DesktopView.h"
#include <cmath>

@interface DesktopView ()
@property (nonatomic, strong) NSArray *desktopIcons;
@end

@implementation DesktopView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIcon = -1;
        [self setupDesktopIcons];
    }
    return self;
}

- (void)setupDesktopIcons {
    // Virtual file system paths - completely isolated from real system
    self.desktopIcons = @[
        @{@"name": @"Macintosh HD", @"path": @"/"},
        @{@"name": @"Documents", @"path": @"/Users/Guest/Documents"},
        @{@"name": @"Downloads", @"path": @"/Users/Guest/Downloads"},
        @{@"name": @"Applications", @"path": @"/Applications"},
        @{@"name": @"Trash", @"path": @"/Users/Guest/.Trash"}
    ];
}

- (void)drawRect:(NSRect)dirtyRect {
    // macOS Sonoma-style gradient wallpaper
    NSGradient *wallpaperGradient = [[NSGradient alloc] initWithColorsAndLocations:
        [NSColor colorWithRed:0.05 green:0.10 blue:0.20 alpha:1.0], 0.0,
        [NSColor colorWithRed:0.15 green:0.22 blue:0.38 alpha:1.0], 0.2,
        [NSColor colorWithRed:0.35 green:0.30 blue:0.50 alpha:1.0], 0.4,
        [NSColor colorWithRed:0.60 green:0.40 blue:0.50 alpha:1.0], 0.6,
        [NSColor colorWithRed:0.85 green:0.55 blue:0.45 alpha:1.0], 0.8,
        [NSColor colorWithRed:0.95 green:0.75 blue:0.55 alpha:1.0], 1.0,
        nil];
    [wallpaperGradient drawInRect:self.bounds angle:135];
    
    // Smooth wave overlay for depth
    for (int wave = 0; wave < 3; wave++) {
        NSBezierPath *wavePath = [NSBezierPath bezierPath];
        CGFloat waveY = self.bounds.size.height * (0.25 + wave * 0.12);
        CGFloat amplitude = 40 + wave * 20;
        CGFloat frequency = 0.008 + wave * 0.003;
        
        [wavePath moveToPoint:NSMakePoint(0, waveY)];
        for (CGFloat x = 0; x <= self.bounds.size.width; x += 4) {
            CGFloat y = waveY + std::sin(x * frequency + wave) * amplitude;
            [wavePath lineToPoint:NSMakePoint(x, y)];
        }
        [wavePath lineToPoint:NSMakePoint(self.bounds.size.width, 0)];
        [wavePath lineToPoint:NSMakePoint(0, 0)];
        [wavePath closePath];
        
        [[NSColor colorWithRed:0.1 + wave * 0.05 green:0.15 + wave * 0.05 blue:0.25 + wave * 0.05 alpha:0.15 - wave * 0.03] setFill];
        [wavePath fill];
    }
    
    // Desktop icons - macOS style folder icons
    CGFloat iconX = self.bounds.size.width - 90;
    CGFloat iconSize = 64;
    CGFloat iconSpacing = 90;
    
    NSArray *iconImages = @[@"💻", @"📁", @"⬇️", @"📦", @"🗑️"];
    
    for (NSInteger i = 0; i < (NSInteger)self.desktopIcons.count; i++) {
        NSDictionary *iconData = self.desktopIcons[i];
        CGFloat iconY;
        if (i == 4) { // Trash at bottom
            iconY = 30;
        } else {
            iconY = self.bounds.size.height - 100 - (i * iconSpacing);
        }
        
        NSRect iconRect = NSMakeRect(iconX, iconY, 76, 85);
        
        // Selection highlight (macOS blue selection)
        if (i == self.selectedIcon) {
            [[NSColor colorWithRed:0.25 green:0.50 blue:0.90 alpha:0.35] setFill];
            NSBezierPath *selPath = [NSBezierPath bezierPathWithRoundedRect:iconRect xRadius:6 yRadius:6];
            [selPath fill];
            
            // Selection border
            [[NSColor colorWithRed:0.30 green:0.55 blue:0.95 alpha:0.6] setStroke];
            [selPath setLineWidth:1.5];
            [selPath stroke];
        }
        
        // Draw icon
        NSString *emoji = iconImages[i];
        NSDictionary *iconAttrs = @{NSFontAttributeName: [NSFont systemFontOfSize:48]};
        NSSize emojiSize = [emoji sizeWithAttributes:iconAttrs];
        CGFloat emojiX = iconX + (76 - emojiSize.width) / 2;
        CGFloat emojiY = iconY + 30;
        [emoji drawAtPoint:NSMakePoint(emojiX, emojiY) withAttributes:iconAttrs];
        
        // Label with macOS-style text shadow
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [NSColor colorWithWhite:0 alpha:0.8];
        shadow.shadowOffset = NSMakeSize(0, -1);
        shadow.shadowBlurRadius = 2;
        
        NSDictionary *labelAttrs = @{
            NSFontAttributeName: [NSFont systemFontOfSize:11 weight:NSFontWeightMedium],
            NSForegroundColorAttributeName: [NSColor whiteColor],
            NSParagraphStyleAttributeName: style,
            NSShadowAttributeName: shadow
        };
        
        NSRect labelRect = NSMakeRect(iconX - 10, iconY + 2, 96, 30);
        [iconData[@"name"] drawInRect:labelRect withAttributes:labelAttrs];
    }
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat iconX = self.bounds.size.width - 90;
    CGFloat iconSpacing = 90;
    
    NSInteger previousSelection = self.selectedIcon;
    self.selectedIcon = -1;
    
    for (NSInteger i = 0; i < (NSInteger)self.desktopIcons.count; i++) {
        CGFloat iconY;
        if (i == 4) {
            iconY = 30;
        } else {
            iconY = self.bounds.size.height - 100 - (i * iconSpacing);
        }
        
        NSRect iconRect = NSMakeRect(iconX, iconY, 76, 85);
        if (NSPointInRect(location, iconRect)) {
            self.selectedIcon = i;
            
            // Handle double-click
            if (event.clickCount == 2 && self.delegate) {
                NSDictionary *iconData = self.desktopIcons[i];
                [self.delegate desktopIconDoubleClicked:iconData[@"name"] path:iconData[@"path"]];
            }
            break;
        }
    }
    
    if (self.selectedIcon != previousSelection) {
        [self setNeedsDisplay:YES];
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat iconX = self.bounds.size.width - 90;
    CGFloat iconSpacing = 90;
    
    NSInteger clickedIcon = -1;
    for (NSInteger i = 0; i < (NSInteger)self.desktopIcons.count; i++) {
        CGFloat iconY;
        if (i == 4) {
            iconY = 30;
        } else {
            iconY = self.bounds.size.height - 100 - (i * iconSpacing);
        }
        
        NSRect iconRect = NSMakeRect(iconX, iconY, 76, 85);
        if (NSPointInRect(location, iconRect)) {
            clickedIcon = i;
            break;
        }
    }
    
    NSMenu *contextMenu = [[NSMenu alloc] initWithTitle:@"Context Menu"];
    
    if (clickedIcon >= 0) {
        // Icon context menu
        NSDictionary *iconData = self.desktopIcons[clickedIcon];
        self.selectedIcon = clickedIcon;
        [self setNeedsDisplay:YES];
        
        NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open" action:@selector(contextMenuOpen:) keyEquivalent:@""];
        openItem.representedObject = iconData;
        openItem.target = self;
        [contextMenu addItem:openItem];
        
        NSMenuItem *infoItem = [[NSMenuItem alloc] initWithTitle:@"Get Info" action:@selector(contextMenuGetInfo:) keyEquivalent:@""];
        infoItem.representedObject = iconData;
        infoItem.target = self;
        [contextMenu addItem:infoItem];
        
        [contextMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(contextMenuCopy:) keyEquivalent:@""];
        copyItem.representedObject = iconData;
        copyItem.target = self;
        [contextMenu addItem:copyItem];
    } else {
        // Desktop context menu
        [contextMenu addItemWithTitle:@"New Folder" action:@selector(contextMenuNewFolder:) keyEquivalent:@""];
        [contextMenu addItem:[NSMenuItem separatorItem]];
        [contextMenu addItemWithTitle:@"Change Desktop Background..." action:nil keyEquivalent:@""];
        [contextMenu addItem:[NSMenuItem separatorItem]];
        [contextMenu addItemWithTitle:@"Sort By" action:nil keyEquivalent:@""];
        [contextMenu addItemWithTitle:@"Clean Up" action:nil keyEquivalent:@""];
        [contextMenu addItemWithTitle:@"Show View Options" action:nil keyEquivalent:@""];
        
        for (NSMenuItem *item in contextMenu.itemArray) {
            item.target = self;
        }
    }
    
    [NSMenu popUpContextMenu:contextMenu withEvent:event forView:self];
}

- (void)contextMenuOpen:(NSMenuItem *)sender {
    NSDictionary *iconData = sender.representedObject;
    if (self.delegate) {
        [self.delegate desktopIconDoubleClicked:iconData[@"name"] path:iconData[@"path"]];
    }
}

- (void)contextMenuGetInfo:(NSMenuItem *)sender {
    NSDictionary *iconData = sender.representedObject;
    NSString *path = iconData[@"path"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attrs = [fm attributesOfItemAtPath:path error:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = iconData[@"name"];
    alert.informativeText = [NSString stringWithFormat:@"Path: %@\nSize: %@ bytes\nModified: %@",
                             path,
                             attrs[NSFileSize] ?: @"--",
                             attrs[NSFileModificationDate] ?: @"--"];
    [alert runModal];
}

- (void)contextMenuCopy:(NSMenuItem *)sender {
    NSDictionary *iconData = sender.representedObject;
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[[NSURL fileURLWithPath:iconData[@"path"]]]];
}

- (void)contextMenuNewFolder:(id)sender {
    NSString *desktopPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString *newFolderPath = [desktopPath stringByAppendingPathComponent:@"New Folder"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSInteger counter = 1;
    while ([fm fileExistsAtPath:newFolderPath]) {
        newFolderPath = [desktopPath stringByAppendingPathComponent:[NSString stringWithFormat:@"New Folder %ld", (long)counter++]];
    }
    
    [fm createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
