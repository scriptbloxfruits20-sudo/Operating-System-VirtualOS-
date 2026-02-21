#import "SettingsWindow.h"
#import "../helpers/SystemInfoHelper.h"

@interface SettingsWindow ()
@property (nonatomic, strong) NSWindow *settingsWindow;
@property (nonatomic, strong) NSTableView *categoriesTable;
@property (nonatomic, strong) NSView *detailView;
@property (nonatomic, strong) NSArray *categories;
@end

@implementation SettingsWindow

+ (instancetype)sharedInstance {
    static SettingsWindow *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SettingsWindow alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.categories = @[
            @{@"icon": @"📶", @"name": @"Wi-Fi"},
            @{@"icon": @"🔵", @"name": @"Bluetooth"},
            @{@"icon": @"🌐", @"name": @"Network"},
            @{@"icon": @"🔔", @"name": @"Notifications"},
            @{@"icon": @"🔊", @"name": @"Sound"},
            @{@"icon": @"🎯", @"name": @"Focus"},
            @{@"icon": @"⏰", @"name": @"Screen Time"},
            @{@"icon": @"🖥", @"name": @"Displays"},
            @{@"icon": @"🎨", @"name": @"Appearance"},
            @{@"icon": @"🔒", @"name": @"Privacy & Security"},
            @{@"icon": @"🖱", @"name": @"Trackpad"},
            @{@"icon": @"⌨️", @"name": @"Keyboard"},
            @{@"icon": @"🔋", @"name": @"Battery"},
            @{@"icon": @"ℹ️", @"name": @"About"}
        ];
    }
    return self;
}

- (void)showWindow {
    if (self.settingsWindow) {
        [self.settingsWindow makeKeyAndOrderFront:nil];
        return;
    }
    
    NSRect frame = NSMakeRect(0, 0, 780, 520);
    self.settingsWindow = [[NSWindow alloc] initWithContentRect:frame
                                                      styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    [self.settingsWindow setTitle:@"System Settings"];
    [self.settingsWindow center];
    
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    contentView.wantsLayer = YES;
    contentView.layer.backgroundColor = [[NSColor colorWithWhite:0.95 alpha:1.0] CGColor];
    [self.settingsWindow setContentView:contentView];
    
    // Sidebar
    NSView *sidebar = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 230, frame.size.height)];
    sidebar.wantsLayer = YES;
    sidebar.layer.backgroundColor = [[NSColor colorWithWhite:0.92 alpha:1.0] CGColor];
    [contentView addSubview:sidebar];
    
    // Search field
    NSSearchField *searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(12, frame.size.height - 45, 206, 28)];
    searchField.placeholderString = @"Search";
    [sidebar addSubview:searchField];
    
    // Categories scroll view
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 230, frame.size.height - 55)];
    scrollView.hasVerticalScroller = YES;
    scrollView.autohidesScrollers = YES;
    
    self.categoriesTable = [[NSTableView alloc] initWithFrame:scrollView.bounds];
    self.categoriesTable.dataSource = self;
    self.categoriesTable.delegate = self;
    self.categoriesTable.rowHeight = 36;
    self.categoriesTable.headerView = nil;
    self.categoriesTable.backgroundColor = [NSColor clearColor];
    self.categoriesTable.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"category"];
    col.width = 230;
    [self.categoriesTable addTableColumn:col];
    
    scrollView.documentView = self.categoriesTable;
    [sidebar addSubview:scrollView];
    
    // Detail view
    self.detailView = [[NSView alloc] initWithFrame:NSMakeRect(230, 0, frame.size.width - 230, frame.size.height)];
    self.detailView.wantsLayer = YES;
    self.detailView.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    [contentView addSubview:self.detailView];
    
    // Show default view (About)
    [self showAboutPanel];
    
    [self.settingsWindow makeKeyAndOrderFront:nil];
}

- (void)showAboutPanel {
    // Clear previous content
    for (NSView *subview in [self.detailView.subviews copy]) {
        [subview removeFromSuperview];
    }
    
    CGFloat y = self.detailView.bounds.size.height - 80;
    
    // Title
    NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 400, 35)];
    title.stringValue = @"About";
    title.font = [NSFont systemFontOfSize:28 weight:NSFontWeightBold];
    title.bezeled = NO;
    title.editable = NO;
    title.drawsBackground = NO;
    [self.detailView addSubview:title];
    
    y -= 80;
    
    // Computer icon
    NSTextField *icon = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 80, 80)];
    icon.stringValue = @"🖥";
    icon.font = [NSFont systemFontOfSize:55];
    icon.bezeled = NO;
    icon.editable = NO;
    icon.drawsBackground = NO;
    [self.detailView addSubview:icon];
    
    // Computer name
    NSTextField *computerName = [[NSTextField alloc] initWithFrame:NSMakeRect(120, y + 50, 350, 25)];
    computerName.stringValue = [SystemInfoHelper computerName];
    computerName.font = [NSFont systemFontOfSize:18 weight:NSFontWeightSemibold];
    computerName.bezeled = NO;
    computerName.editable = NO;
    computerName.drawsBackground = NO;
    [self.detailView addSubview:computerName];
    
    // macOS version
    NSTextField *osVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(120, y + 25, 350, 20)];
    osVersion.stringValue = [SystemInfoHelper osVersion];
    osVersion.font = [NSFont systemFontOfSize:13];
    osVersion.textColor = [NSColor grayColor];
    osVersion.bezeled = NO;
    osVersion.editable = NO;
    osVersion.drawsBackground = NO;
    [self.detailView addSubview:osVersion];
    
    y -= 50;
    
    // System info section
    NSArray *infoItems = @[
        @{@"label": @"Chip", @"value": [SystemInfoHelper cpuModel]},
        @{@"label": @"Memory", @"value": [SystemInfoHelper memorySize]},
        @{@"label": @"Serial Number", @"value": [SystemInfoHelper serialNumber]},
        @{@"label": @"Uptime", @"value": [SystemInfoHelper uptime]}
    ];
    
    for (NSDictionary *item in infoItems) {
        y -= 35;
        
        NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 130, 20)];
        label.stringValue = [NSString stringWithFormat:@"%@:", item[@"label"]];
        label.font = [NSFont systemFontOfSize:13];
        label.textColor = [NSColor grayColor];
        label.alignment = NSTextAlignmentRight;
        label.bezeled = NO;
        label.editable = NO;
        label.drawsBackground = NO;
        [self.detailView addSubview:label];
        
        NSTextField *value = [[NSTextField alloc] initWithFrame:NSMakeRect(170, y, 350, 20)];
        value.stringValue = item[@"value"];
        value.font = [NSFont systemFontOfSize:13];
        value.bezeled = NO;
        value.editable = NO;
        value.drawsBackground = NO;
        [self.detailView addSubview:value];
    }
    
    // Buttons
    y -= 50;
    
    NSButton *systemReportBtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, y, 150, 32)];
    systemReportBtn.title = @"System Report...";
    systemReportBtn.bezelStyle = NSBezelStyleRounded;
    [self.detailView addSubview:systemReportBtn];
    
    NSButton *softwareUpdateBtn = [[NSButton alloc] initWithFrame:NSMakeRect(190, y, 150, 32)];
    softwareUpdateBtn.title = @"Software Update...";
    softwareUpdateBtn.bezelStyle = NSBezelStyleRounded;
    [self.detailView addSubview:softwareUpdateBtn];
}

- (void)showWiFiPanel {
    for (NSView *subview in [self.detailView.subviews copy]) {
        [subview removeFromSuperview];
    }
    
    CGFloat y = self.detailView.bounds.size.height - 80;
    
    NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 400, 35)];
    title.stringValue = @"Wi-Fi";
    title.font = [NSFont systemFontOfSize:28 weight:NSFontWeightBold];
    title.bezeled = NO;
    title.editable = NO;
    title.drawsBackground = NO;
    [self.detailView addSubview:title];
    
    y -= 60;
    
    // Wi-Fi toggle
    NSTextField *wifiLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 100, 25)];
    wifiLabel.stringValue = @"Wi-Fi";
    wifiLabel.font = [NSFont systemFontOfSize:15 weight:NSFontWeightMedium];
    wifiLabel.bezeled = NO;
    wifiLabel.editable = NO;
    wifiLabel.drawsBackground = NO;
    [self.detailView addSubview:wifiLabel];
    
    NSButton *wifiToggle = [[NSButton alloc] initWithFrame:NSMakeRect(430, y, 60, 25)];
    [wifiToggle setButtonType:NSButtonTypeSwitch];
    wifiToggle.title = @"";
    wifiToggle.state = NSControlStateValueOn;
    [self.detailView addSubview:wifiToggle];
    
    y -= 50;
    
    // Networks list header
    NSTextField *networksLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 200, 20)];
    networksLabel.stringValue = @"Known Networks";
    networksLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    networksLabel.textColor = [NSColor grayColor];
    networksLabel.bezeled = NO;
    networksLabel.editable = NO;
    networksLabel.drawsBackground = NO;
    [self.detailView addSubview:networksLabel];
    
    y -= 40;
    
    // Sample networks
    NSArray *networks = @[@"Home Network", @"Office WiFi", @"Coffee Shop"];
    for (NSString *network in networks) {
        NSTextField *networkName = [[NSTextField alloc] initWithFrame:NSMakeRect(30, y, 400, 25)];
        networkName.stringValue = [NSString stringWithFormat:@"📶  %@", network];
        networkName.font = [NSFont systemFontOfSize:14];
        networkName.bezeled = NO;
        networkName.editable = NO;
        networkName.drawsBackground = NO;
        [self.detailView addSubview:networkName];
        
        y -= 35;
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.categories.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 230, 36)];
    
    NSDictionary *category = self.categories[row];
    
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 8, 200, 20)];
    label.stringValue = [NSString stringWithFormat:@"%@  %@", category[@"icon"], category[@"name"]];
    label.font = [NSFont systemFontOfSize:13];
    label.bezeled = NO;
    label.editable = NO;
    label.drawsBackground = NO;
    [cell addSubview:label];
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.categoriesTable.selectedRow;
    if (row < 0) return;
    
    NSDictionary *category = self.categories[row];
    NSString *name = category[@"name"];
    
    if ([name isEqualToString:@"About"]) {
        [self showAboutPanel];
    } else if ([name isEqualToString:@"Wi-Fi"]) {
        [self showWiFiPanel];
    } else {
        // Generic panel for other settings
        for (NSView *subview in [self.detailView.subviews copy]) {
            [subview removeFromSuperview];
        }
        
        NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(30, self.detailView.bounds.size.height - 80, 400, 35)];
        title.stringValue = name;
        title.font = [NSFont systemFontOfSize:28 weight:NSFontWeightBold];
        title.bezeled = NO;
        title.editable = NO;
        title.drawsBackground = NO;
        [self.detailView addSubview:title];
        
        NSTextField *placeholder = [[NSTextField alloc] initWithFrame:NSMakeRect(30, self.detailView.bounds.size.height / 2, 400, 30)];
        placeholder.stringValue = [NSString stringWithFormat:@"%@ settings will appear here", name];
        placeholder.font = [NSFont systemFontOfSize:14];
        placeholder.textColor = [NSColor grayColor];
        placeholder.bezeled = NO;
        placeholder.editable = NO;
        placeholder.drawsBackground = NO;
        [self.detailView addSubview:placeholder];
    }
}

@end
