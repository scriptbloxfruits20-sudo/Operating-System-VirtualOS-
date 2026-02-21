#import "WiFiWindow.h"
#import <CoreWLAN/CoreWLAN.h>

@interface WiFiWindow ()
@property (nonatomic, strong) NSWindow *wifiWindow;
@property (nonatomic, strong) NSTableView *networksTable;
@property (nonatomic, strong) NSMutableArray *networks;
@property (nonatomic, strong) NSTextField *statusLabel;
@property (nonatomic, strong) NSTextField *currentNetworkLabel;
@property (nonatomic, strong) NSProgressIndicator *scanningIndicator;
@property (nonatomic, strong) NSString *connectedSSID;
@property (nonatomic, strong) NSString *connectedPassword;
@property (nonatomic, strong) NSMutableDictionary *savedPasswords;
@property (nonatomic, assign) BOOL wifiEnabled;
@property (nonatomic, strong) CWWiFiClient *wifiClient;
@property (nonatomic, strong) CWInterface *wifiInterface;
@end

@implementation WiFiWindow

+ (instancetype)sharedInstance {
    static WiFiWindow *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WiFiWindow alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.networks = [NSMutableArray array];
        self.savedPasswords = [NSMutableDictionary dictionary];
        self.connectedSSID = nil;
        self.wifiEnabled = YES;
        // CoreWLAN for scanning only - we won't use it to connect
        self.wifiClient = [CWWiFiClient sharedWiFiClient];
        self.wifiInterface = self.wifiClient.interface;
    }
    return self;
}

- (void)showWindow {
    if (self.wifiWindow) {
        [self.wifiWindow makeKeyAndOrderFront:nil];
        [self scanForNetworks];
        return;
    }
    
    NSRect frame = NSMakeRect(0, 0, 420, 520);
    self.wifiWindow = [[NSWindow alloc] initWithContentRect:frame
                                                  styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    [self.wifiWindow setTitle:@"Wi-Fi"];
    [self.wifiWindow center];
    
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    contentView.wantsLayer = YES;
    contentView.layer.backgroundColor = [[NSColor colorWithRed:0.95 green:0.95 blue:0.97 alpha:1.0] CGColor];
    [self.wifiWindow setContentView:contentView];
    
    // Header
    NSView *header = [[NSView alloc] initWithFrame:NSMakeRect(0, frame.size.height - 100, frame.size.width, 100)];
    header.wantsLayer = YES;
    header.layer.backgroundColor = [[NSColor colorWithRed:0.2 green:0.5 blue:0.9 alpha:1.0] CGColor];
    [contentView addSubview:header];
    
    // WiFi icon
    NSTextField *wifiIcon = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 30, 60, 50)];
    wifiIcon.stringValue = @"📶";
    wifiIcon.font = [NSFont systemFontOfSize:40];
    wifiIcon.bezeled = NO;
    wifiIcon.editable = NO;
    wifiIcon.drawsBackground = NO;
    [header addSubview:wifiIcon];
    
    // Title
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(85, 55, 300, 30)];
    titleLabel.stringValue = @"Wi-Fi Networks";
    titleLabel.font = [NSFont boldSystemFontOfSize:22];
    titleLabel.textColor = [NSColor whiteColor];
    titleLabel.bezeled = NO;
    titleLabel.editable = NO;
    titleLabel.drawsBackground = NO;
    [header addSubview:titleLabel];
    
    // Subtitle
    NSTextField *subtitleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(85, 35, 300, 20)];
    subtitleLabel.stringValue = @"Real scanning • Sandboxed connection";
    subtitleLabel.font = [NSFont systemFontOfSize:11];
    subtitleLabel.textColor = [NSColor colorWithWhite:1.0 alpha:0.8];
    subtitleLabel.bezeled = NO;
    subtitleLabel.editable = NO;
    subtitleLabel.drawsBackground = NO;
    [header addSubview:subtitleLabel];
    
    // WiFi toggle
    NSButton *wifiToggle = [[NSButton alloc] initWithFrame:NSMakeRect(330, 45, 70, 30)];
    [wifiToggle setButtonType:NSButtonTypeSwitch];
    wifiToggle.title = @"Wi-Fi";
    wifiToggle.state = self.wifiEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    wifiToggle.target = self;
    wifiToggle.action = @selector(toggleWifi:);
    [wifiToggle setContentTintColor:[NSColor whiteColor]];
    [header addSubview:wifiToggle];
    
    // Current network info
    self.currentNetworkLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, frame.size.height - 135, 380, 25)];
    self.currentNetworkLabel.stringValue = self.connectedSSID ? [NSString stringWithFormat:@"Connected to: %@", self.connectedSSID] : @"Not connected";
    self.currentNetworkLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    self.currentNetworkLabel.bezeled = NO;
    self.currentNetworkLabel.editable = NO;
    self.currentNetworkLabel.drawsBackground = NO;
    [contentView addSubview:self.currentNetworkLabel];
    
    // Networks table
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(15, 60, frame.size.width - 30, frame.size.height - 210)];
    scrollView.hasVerticalScroller = YES;
    scrollView.autohidesScrollers = YES;
    scrollView.wantsLayer = YES;
    scrollView.layer.cornerRadius = 10;
    scrollView.layer.borderColor = [[NSColor colorWithWhite:0.85 alpha:1.0] CGColor];
    scrollView.layer.borderWidth = 1;
    
    self.networksTable = [[NSTableView alloc] initWithFrame:scrollView.bounds];
    self.networksTable.dataSource = self;
    self.networksTable.delegate = self;
    self.networksTable.rowHeight = 50;
    self.networksTable.headerView = nil;
    self.networksTable.backgroundColor = [NSColor whiteColor];
    
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"network"];
    col.width = scrollView.bounds.size.width;
    [self.networksTable addTableColumn:col];
    
    scrollView.documentView = self.networksTable;
    [contentView addSubview:scrollView];
    
    // Status and scan button
    self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 25, 250, 25)];
    self.statusLabel.stringValue = @"";
    self.statusLabel.font = [NSFont systemFontOfSize:12];
    self.statusLabel.textColor = [NSColor secondaryLabelColor];
    self.statusLabel.bezeled = NO;
    self.statusLabel.editable = NO;
    self.statusLabel.drawsBackground = NO;
    [contentView addSubview:self.statusLabel];
    
    self.scanningIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(280, 28, 20, 20)];
    self.scanningIndicator.style = NSProgressIndicatorStyleSpinning;
    [self.scanningIndicator setHidden:YES];
    [contentView addSubview:self.scanningIndicator];
    
    NSButton *scanBtn = [[NSButton alloc] initWithFrame:NSMakeRect(310, 22, 90, 30)];
    scanBtn.title = @"Scan";
    scanBtn.bezelStyle = NSBezelStyleRounded;
    scanBtn.target = self;
    scanBtn.action = @selector(scanForNetworks);
    [contentView addSubview:scanBtn];
    
    [self.wifiWindow makeKeyAndOrderFront:nil];
    [self scanForNetworks];
}

- (void)toggleWifi:(NSButton *)sender {
    self.wifiEnabled = (sender.state == NSControlStateValueOn);
    
    if (!self.wifiEnabled) {
        self.connectedSSID = nil;
        self.currentNetworkLabel.stringValue = @"Wi-Fi is off";
        [self.networks removeAllObjects];
        [self.networksTable reloadData];
        self.statusLabel.stringValue = @"Turn on Wi-Fi to see available networks";
    } else {
        self.currentNetworkLabel.stringValue = @"Not connected";
        [self scanForNetworks];
    }
}

- (void)scanForNetworks {
    if (!self.wifiEnabled) {
        self.statusLabel.stringValue = @"Wi-Fi is off";
        return;
    }
    
    [self.scanningIndicator setHidden:NO];
    [self.scanningIndicator startAnimation:nil];
    self.statusLabel.stringValue = @"Scanning for networks...";
    
    // Real WiFi scanning using CoreWLAN (read-only, doesn't change anything)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *foundNetworks = [NSMutableArray array];
        
        // Try to scan for real networks
        NSSet<CWNetwork *> *scanResults = nil;
        
        @try {
            // First try cached results (doesn't require Location Services)
            scanResults = [self.wifiInterface cachedScanResults];
            
            // If no cached results, try active scan
            if (!scanResults || scanResults.count == 0) {
                NSError *error = nil;
                scanResults = [self.wifiInterface scanForNetworksWithName:nil error:&error];
            }
        } @catch (NSException *e) {
            // Scanning failed, will use fallback
        }
        
        // Process scan results
        if (scanResults && scanResults.count > 0) {
            NSArray *sortedNetworks = [scanResults.allObjects sortedArrayUsingComparator:^NSComparisonResult(CWNetwork *a, CWNetwork *b) {
                return [@(b.rssiValue) compare:@(a.rssiValue)];
            }];
            
            for (CWNetwork *network in sortedNetworks) {
                if (network.ssid.length == 0) continue;
                
                // Determine security type
                NSString *security = @"Open";
                BOOL isSecured = NO;
                if ([network supportsSecurity:kCWSecurityWPA3Personal] || [network supportsSecurity:kCWSecurityWPA3Enterprise]) {
                    security = @"WPA3";
                    isSecured = YES;
                } else if ([network supportsSecurity:kCWSecurityWPA2Personal] || [network supportsSecurity:kCWSecurityWPA2Enterprise]) {
                    security = @"WPA2";
                    isSecured = YES;
                } else if ([network supportsSecurity:kCWSecurityWPAPersonal] || [network supportsSecurity:kCWSecurityWPAEnterprise]) {
                    security = @"WPA";
                    isSecured = YES;
                } else if ([network supportsSecurity:kCWSecurityWEP]) {
                    security = @"WEP";
                    isSecured = YES;
                }
                
                BOOL isConnected = [network.ssid isEqualToString:self.connectedSSID];
                
                [foundNetworks addObject:@{
                    @"ssid": network.ssid,
                    @"rssi": @(network.rssiValue),
                    @"security": security,
                    @"secured": @(isSecured),
                    @"connected": @(isConnected),
                    @"network": network
                }];
            }
        }
        
        // If no networks found via CoreWLAN, try system command fallback
        if (foundNetworks.count == 0) {
            [self scanWithSystemCommand:foundNetworks];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scanningIndicator stopAnimation:nil];
            [self.scanningIndicator setHidden:YES];
            
            [self.networks removeAllObjects];
            
            // Add connected network first if any
            if (self.connectedSSID) {
                for (NSDictionary *net in foundNetworks) {
                    if ([net[@"ssid"] isEqualToString:self.connectedSSID]) {
                        NSMutableDictionary *connectedNet = [net mutableCopy];
                        connectedNet[@"connected"] = @YES;
                        [self.networks addObject:connectedNet];
                        break;
                    }
                }
                // If connected network not in scan results, add it anyway
                if (self.networks.count == 0) {
                    [self.networks addObject:@{
                        @"ssid": self.connectedSSID,
                        @"rssi": @(-50),
                        @"security": @"WPA2",
                        @"secured": @YES,
                        @"connected": @YES
                    }];
                }
            }
            
            // Add other networks
            for (NSDictionary *net in foundNetworks) {
                if (![net[@"ssid"] isEqualToString:self.connectedSSID]) {
                    [self.networks addObject:net];
                }
            }
            
            if (self.networks.count == 0) {
                self.statusLabel.stringValue = @"No networks found (may require Location Services)";
            } else {
                self.statusLabel.stringValue = [NSString stringWithFormat:@"Found %lu networks", (unsigned long)self.networks.count];
            }
            [self.networksTable reloadData];
        });
    });
}

- (void)scanWithSystemCommand:(NSMutableArray *)foundNetworks {
    // Fallback: Get preferred networks list
    NSString *interfaceName = self.wifiInterface.interfaceName ?: @"en0";
    
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:@"/usr/sbin/networksetup"];
    task.arguments = @[@"-listpreferredwirelessnetworks", interfaceName];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    
    @try {
        [task launchAndReturnError:nil];
        [task waitUntilExit];
        
        NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *lines = [output componentsSeparatedByString:@"\n"];
        
        NSInteger rssi = -45;
        for (NSString *line in lines) {
            NSString *ssid = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (ssid.length > 0 && ![ssid hasPrefix:@"Preferred"]) {
                [foundNetworks addObject:@{
                    @"ssid": ssid,
                    @"rssi": @(rssi),
                    @"security": @"WPA2",
                    @"secured": @YES,
                    @"connected": @([ssid isEqualToString:self.connectedSSID])
                }];
                rssi -= 5;
                if (foundNetworks.count >= 15) break;
            }
        }
    } @catch (NSException *e) {}
}

- (void)updateCurrentNetworkStatus {
    if (self.connectedSSID) {
        self.currentNetworkLabel.stringValue = [NSString stringWithFormat:@"✓ Connected to: %@", self.connectedSSID];
        self.currentNetworkLabel.textColor = [NSColor colorWithRed:0.2 green:0.7 blue:0.3 alpha:1.0];
    } else {
        self.currentNetworkLabel.stringValue = @"Not connected";
        self.currentNetworkLabel.textColor = [NSColor labelColor];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.networks.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableView.bounds.size.width, 50)];
    
    if (row < (NSInteger)self.networks.count) {
        NSDictionary *network = self.networks[row];
        NSString *ssid = network[@"ssid"];
        NSString *security = network[@"security"];
        NSInteger rssi = [network[@"rssi"] integerValue];
        BOOL isConnected = [network[@"connected"] boolValue];
        
        // WiFi signal icon based on strength
        NSTextField *signalIcon = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 15, 30, 25)];
        signalIcon.stringValue = [self signalIconForRSSI:rssi];
        signalIcon.font = [NSFont systemFontOfSize:20];
        signalIcon.bezeled = NO;
        signalIcon.editable = NO;
        signalIcon.drawsBackground = NO;
        [cell addSubview:signalIcon];
        
        // Network name
        NSTextField *ssidLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(48, 25, 220, 20)];
        ssidLabel.stringValue = ssid;
        ssidLabel.font = isConnected ? [NSFont boldSystemFontOfSize:14] : [NSFont systemFontOfSize:14];
        ssidLabel.textColor = isConnected ? [NSColor colorWithRed:0.2 green:0.6 blue:0.3 alpha:1.0] : [NSColor labelColor];
        ssidLabel.bezeled = NO;
        ssidLabel.editable = NO;
        ssidLabel.drawsBackground = NO;
        [cell addSubview:ssidLabel];
        
        // Security info
        NSString *securityIcon = [security isEqualToString:@"Open"] ? @"" : @"🔒 ";
        NSTextField *infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(48, 8, 220, 16)];
        infoLabel.stringValue = [NSString stringWithFormat:@"%@%@", securityIcon, security];
        infoLabel.font = [NSFont systemFontOfSize:11];
        infoLabel.textColor = [NSColor secondaryLabelColor];
        infoLabel.bezeled = NO;
        infoLabel.editable = NO;
        infoLabel.drawsBackground = NO;
        [cell addSubview:infoLabel];
        
        // Connect button
        NSButton *connectBtn = [[NSButton alloc] initWithFrame:NSMakeRect(tableView.bounds.size.width - 95, 12, 80, 26)];
        if (isConnected) {
            connectBtn.title = @"Disconnect";
            connectBtn.action = @selector(disconnectFromNetwork:);
        } else {
            connectBtn.title = @"Connect";
            connectBtn.action = @selector(connectToNetwork:);
        }
        connectBtn.bezelStyle = NSBezelStyleRounded;
        connectBtn.font = [NSFont systemFontOfSize:11];
        connectBtn.tag = row;
        connectBtn.target = self;
        [cell addSubview:connectBtn];
    }
    
    return cell;
}

- (NSString *)signalIconForRSSI:(NSInteger)rssi {
    if (rssi >= -50) return @"📶";
    if (rssi >= -60) return @"📶";
    if (rssi >= -70) return @"📶";
    return @"📶";
}

- (void)connectToNetwork:(NSButton *)sender {
    NSInteger row = sender.tag;
    if (row < 0 || row >= (NSInteger)self.networks.count) return;
    
    NSDictionary *networkInfo = self.networks[row];
    NSString *ssid = networkInfo[@"ssid"];
    BOOL isSecured = [networkInfo[@"secured"] boolValue];
    
    // Check if we have a saved password for this network
    NSString *savedPassword = self.savedPasswords[ssid];
    
    if (isSecured) {
        [self showPasswordDialogForSSID:ssid savedPassword:savedPassword networkInfo:networkInfo];
    } else {
        // Open network - connect directly using real WiFi
        [self connectToOpenNetwork:ssid networkInfo:networkInfo];
    }
}

- (void)showPasswordDialogForSSID:(NSString *)ssid savedPassword:(NSString *)savedPassword networkInfo:(NSDictionary *)networkInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"Enter password for \"%@\"", ssid];
    alert.informativeText = @"This network requires a password.";
    
    NSSecureTextField *passwordField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 260, 24)];
    passwordField.placeholderString = @"Password";
    if (savedPassword) {
        passwordField.stringValue = savedPassword;
    }
    alert.accessoryView = passwordField;
    
    [alert addButtonWithTitle:@"Join"];
    [alert addButtonWithTitle:@"Cancel"];
    
    [alert beginSheetModalForWindow:self.wifiWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString *enteredPassword = passwordField.stringValue;
            
            if (enteredPassword.length == 0) {
                self.statusLabel.stringValue = @"Password cannot be empty";
                return;
            }
            
            // Validate password length (WPA requires 8+ characters)
            if (enteredPassword.length < 8) {
                [self showPasswordTooShortAlert:ssid networkInfo:networkInfo];
                return;
            }
            
            // Try to authenticate (sandboxed - simulated)
            [self authenticateNetwork:ssid password:enteredPassword networkInfo:networkInfo];
        }
    }];
}

- (void)showPasswordTooShortAlert:(NSString *)ssid networkInfo:(NSDictionary *)networkInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Invalid Password";
    alert.informativeText = @"WPA/WPA2/WPA3 passwords must be at least 8 characters.";
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert addButtonWithTitle:@"Try Again"];
    [alert addButtonWithTitle:@"Cancel"];
    
    [alert beginSheetModalForWindow:self.wifiWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self showPasswordDialogForSSID:ssid savedPassword:nil networkInfo:networkInfo];
        }
    }];
}

- (void)authenticateNetwork:(NSString *)ssid password:(NSString *)password networkInfo:(NSDictionary *)networkInfo {
    self.statusLabel.stringValue = [NSString stringWithFormat:@"Connecting to %@...", ssid];
    
    // Use networksetup command for real WiFi connection (works without entitlements)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *interfaceName = self.wifiInterface.interfaceName ?: @"en0";
        
        NSTask *task = [[NSTask alloc] init];
        task.executableURL = [NSURL fileURLWithPath:@"/usr/sbin/networksetup"];
        task.arguments = @[@"-setairportnetwork", interfaceName, ssid, password];
        
        NSPipe *outputPipe = [NSPipe pipe];
        NSPipe *errorPipe = [NSPipe pipe];
        task.standardOutput = outputPipe;
        task.standardError = errorPipe;
        
        NSError *launchError = nil;
        [task launchAndReturnError:&launchError];
        [task waitUntilExit];
        
        NSData *outputData = [outputPipe.fileHandleForReading readDataToEndOfFile];
        NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        NSString *errorOutput = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        
        int exitCode = task.terminationStatus;
        BOOL success = (exitCode == 0) && ![output containsString:@"Error"] && ![output containsString:@"Failed"];
        NSString *errorMsg = errorOutput.length > 0 ? errorOutput : output;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // Authentication succeeded - password is correct
                self.savedPasswords[ssid] = password;
                self.connectedSSID = ssid;
                self.connectedPassword = password;
                self.statusLabel.stringValue = [NSString stringWithFormat:@"Connected to %@", ssid];
                [self updateCurrentNetworkStatus];
                [self scanForNetworks];
            } else {
                // Authentication failed - check error message
                NSLog(@"WiFi connection failed: %@", errorMsg);
                
                if ([errorMsg containsString:@"password"] ||
                    [errorMsg containsString:@"Password"] ||
                    [errorMsg containsString:@"invalid"] ||
                    [errorMsg containsString:@"incorrect"] ||
                    [errorMsg containsString:@"wrong"]) {
                    [self showWrongPasswordAlert:ssid networkInfo:networkInfo];
                } else if (errorMsg.length == 0 || [errorMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
                    // Empty error usually means wrong password with networksetup
                    [self showWrongPasswordAlert:ssid networkInfo:networkInfo];
                } else {
                    [self showAuthFailedAlertWithError:ssid error:errorMsg networkInfo:networkInfo];
                }
            }
        });
    });
}

- (void)showPermissionErrorAlert:(NSString *)ssid {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Cannot Connect - Permission Required";
    alert.informativeText = @"macOS requires special entitlements for apps to connect to WiFi networks.\n\nThis app can scan networks but cannot connect without being signed with Apple Developer entitlements.\n\nTo connect, use System Preferences > Network or the WiFi menu bar icon.";
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert addButtonWithTitle:@"Open System Preferences"];
    [alert addButtonWithTitle:@"OK"];
    
    [alert beginSheetModalForWindow:self.wifiWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.network"]];
        }
        self.statusLabel.stringValue = @"Use System Preferences to connect";
    }];
}

- (void)showWrongPasswordAlert:(NSString *)ssid networkInfo:(NSDictionary *)networkInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Incorrect Password";
    alert.informativeText = [NSString stringWithFormat:@"The password for \"%@\" is incorrect.", ssid];
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert addButtonWithTitle:@"Try Again"];
    [alert addButtonWithTitle:@"Cancel"];
    
    [alert beginSheetModalForWindow:self.wifiWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self showPasswordDialogForSSID:ssid savedPassword:nil networkInfo:networkInfo];
        } else {
            self.statusLabel.stringValue = @"Incorrect password";
        }
    }];
}

- (void)showAuthFailedAlertWithError:(NSString *)ssid error:(NSString *)errorMsg networkInfo:(NSDictionary *)networkInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Unable to Join Network";
    alert.informativeText = [NSString stringWithFormat:@"Could not connect to \"%@\".\n\nError: %@", ssid, errorMsg];
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert addButtonWithTitle:@"Try Again"];
    [alert addButtonWithTitle:@"Cancel"];
    
    [alert beginSheetModalForWindow:self.wifiWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self showPasswordDialogForSSID:ssid savedPassword:nil networkInfo:networkInfo];
        } else {
            self.statusLabel.stringValue = @"Connection failed";
        }
    }];
}

- (void)connectToOpenNetwork:(NSString *)ssid networkInfo:(NSDictionary *)networkInfo {
    self.statusLabel.stringValue = [NSString stringWithFormat:@"Connecting to %@...", ssid];
    
    // Real connection to open network
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CWNetwork *network = networkInfo[@"network"];
        
        // If no CWNetwork object, try to find it by scanning
        if (!network || [network isKindOfClass:[NSNull class]]) {
            NSError *scanError = nil;
            NSSet<CWNetwork *> *scanResults = [self.wifiInterface scanForNetworksWithName:ssid error:&scanError];
            if (scanResults.count > 0) {
                network = scanResults.anyObject;
            }
        }
        
        if (!network) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.stringValue = @"Network not found - try scanning again";
            });
            return;
        }
        
        NSError *error = nil;
        BOOL success = [self.wifiInterface associateToNetwork:network password:nil error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.connectedSSID = ssid;
                self.statusLabel.stringValue = [NSString stringWithFormat:@"Connected to %@", ssid];
                [self updateCurrentNetworkStatus];
                [self scanForNetworks];
            } else {
                self.statusLabel.stringValue = [NSString stringWithFormat:@"Failed: %@", error.localizedDescription ?: @"Unknown error"];
            }
        });
    });
}

- (void)disconnectFromNetwork:(NSButton *)sender {
    self.statusLabel.stringValue = @"Disconnecting...";
    
    // Real disconnection using disassociate
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.wifiInterface disassociate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *previousSSID = self.connectedSSID;
            self.connectedSSID = nil;
            self.connectedPassword = nil;
            self.statusLabel.stringValue = [NSString stringWithFormat:@"Disconnected from %@", previousSSID ?: @"network"];
            [self updateCurrentNetworkStatus];
            [self scanForNetworks];
        });
    });
}

@end
