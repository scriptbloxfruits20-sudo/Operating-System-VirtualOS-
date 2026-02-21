#import "MessagesWindow.h"

@interface MessagesWindow ()
@property (nonatomic, strong) NSWindow *messagesWindow;
@property (nonatomic, strong) NSWindow *addContactWindow;
@property (nonatomic, strong) NSTableView *contactsTable;
@property (nonatomic, strong) NSScrollView *chatScrollView;
@property (nonatomic, strong) NSView *chatContainer;
@property (nonatomic, strong) NSTextField *messageField;
@property (nonatomic, strong) NSTextField *chatTitleField;
@property (nonatomic, strong) NSTextField *addNameField;
@property (nonatomic, strong) NSTextField *addPhoneField;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableDictionary *conversations;
@property (nonatomic, strong) NSMutableArray *currentMessages;
@property (nonatomic, assign) NSInteger selectedContact;
@end

@implementation MessagesWindow

+ (instancetype)sharedInstance {
    static MessagesWindow *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MessagesWindow alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedContact = -1;
        self.contacts = [NSMutableArray array];
        self.conversations = [NSMutableDictionary dictionary];
        self.currentMessages = [NSMutableArray array];
        
        // Load saved contacts
        [self loadContacts];
    }
    return self;
}

- (void)loadContacts {
    NSString *contactsPath = [self contactsFilePath];
    NSArray *savedContacts = [NSArray arrayWithContentsOfFile:contactsPath];
    if (savedContacts) {
        [self.contacts addObjectsFromArray:savedContacts];
    }
    
    NSString *conversationsPath = [self conversationsFilePath];
    NSDictionary *savedConversations = [NSDictionary dictionaryWithContentsOfFile:conversationsPath];
    if (savedConversations) {
        [self.conversations addEntriesFromDictionary:savedConversations];
    }
}

- (void)saveContacts {
    NSString *contactsPath = [self contactsFilePath];
    [self.contacts writeToFile:contactsPath atomically:YES];
    
    NSString *conversationsPath = [self conversationsFilePath];
    [self.conversations writeToFile:conversationsPath atomically:YES];
}

- (NSString *)contactsFilePath {
    NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *appFolder = [appSupport stringByAppendingPathComponent:@"macOSDesktop"];
    [[NSFileManager defaultManager] createDirectoryAtPath:appFolder withIntermediateDirectories:YES attributes:nil error:nil];
    return [appFolder stringByAppendingPathComponent:@"contacts.plist"];
}

- (NSString *)conversationsFilePath {
    NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *appFolder = [appSupport stringByAppendingPathComponent:@"macOSDesktop"];
    return [appFolder stringByAppendingPathComponent:@"conversations.plist"];
}

- (void)showWindow {
    if (self.messagesWindow) {
        [self.messagesWindow makeKeyAndOrderFront:nil];
        return;
    }
    
    NSRect frame = NSMakeRect(0, 0, 800, 550);
    self.messagesWindow = [[NSWindow alloc] initWithContentRect:frame
                                                      styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    [self.messagesWindow setTitle:@"Messages"];
    [self.messagesWindow center];
    
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    contentView.wantsLayer = YES;
    contentView.layer.backgroundColor = [[NSColor colorWithWhite:0.95 alpha:1.0] CGColor];
    [self.messagesWindow setContentView:contentView];
    
    // Contacts sidebar
    NSView *sidebar = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 250, frame.size.height)];
    sidebar.wantsLayer = YES;
    sidebar.layer.backgroundColor = [[NSColor colorWithWhite:0.92 alpha:1.0] CGColor];
    [contentView addSubview:sidebar];
    
    // Sidebar header with New Message button
    NSTextField *sidebarTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(15, frame.size.height - 45, 150, 25)];
    sidebarTitle.stringValue = @"Messages";
    sidebarTitle.font = [NSFont boldSystemFontOfSize:18];
    sidebarTitle.bezeled = NO;
    sidebarTitle.editable = NO;
    sidebarTitle.drawsBackground = NO;
    [sidebar addSubview:sidebarTitle];
    
    // New message button
    NSButton *newMsgBtn = [[NSButton alloc] initWithFrame:NSMakeRect(200, frame.size.height - 45, 40, 25)];
    newMsgBtn.title = @"✏️";
    newMsgBtn.bezelStyle = NSBezelStyleRounded;
    newMsgBtn.target = self;
    newMsgBtn.action = @selector(newConversation:);
    [sidebar addSubview:newMsgBtn];
    
    // Search field
    NSSearchField *searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(10, frame.size.height - 80, 230, 28)];
    searchField.placeholderString = @"Search";
    [sidebar addSubview:searchField];
    
    // Contacts table
    NSScrollView *contactsScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 50, 250, frame.size.height - 140)];
    contactsScroll.hasVerticalScroller = YES;
    contactsScroll.autohidesScrollers = YES;
    
    self.contactsTable = [[NSTableView alloc] initWithFrame:contactsScroll.bounds];
    self.contactsTable.dataSource = self;
    self.contactsTable.delegate = self;
    self.contactsTable.rowHeight = 60;
    self.contactsTable.headerView = nil;
    self.contactsTable.backgroundColor = [NSColor clearColor];
    
    NSTableColumn *contactCol = [[NSTableColumn alloc] initWithIdentifier:@"contact"];
    contactCol.width = 250;
    [self.contactsTable addTableColumn:contactCol];
    
    contactsScroll.documentView = self.contactsTable;
    [sidebar addSubview:contactsScroll];
    
    // Add Contact button at bottom of sidebar
    NSButton *addContactBtn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 230, 32)];
    addContactBtn.title = @"➕ Add Contact";
    addContactBtn.bezelStyle = NSBezelStyleRounded;
    addContactBtn.target = self;
    addContactBtn.action = @selector(addContact:);
    [sidebar addSubview:addContactBtn];
    
    // Chat area
    NSView *chatArea = [[NSView alloc] initWithFrame:NSMakeRect(250, 0, frame.size.width - 250, frame.size.height)];
    chatArea.wantsLayer = YES;
    chatArea.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    [contentView addSubview:chatArea];
    
    // Chat header
    NSView *chatHeader = [[NSView alloc] initWithFrame:NSMakeRect(0, chatArea.bounds.size.height - 60, chatArea.bounds.size.width, 60)];
    chatHeader.wantsLayer = YES;
    chatHeader.layer.backgroundColor = [[NSColor colorWithWhite:0.98 alpha:1.0] CGColor];
    [chatArea addSubview:chatHeader];
    
    self.chatTitleField = [[NSTextField alloc] initWithFrame:NSMakeRect(15, 18, 300, 25)];
    self.chatTitleField.stringValue = self.contacts.count > 0 ? self.contacts[0][@"name"] : @"Select a conversation";
    self.chatTitleField.font = [NSFont boldSystemFontOfSize:16];
    self.chatTitleField.bezeled = NO;
    self.chatTitleField.editable = NO;
    self.chatTitleField.drawsBackground = NO;
    [chatHeader addSubview:self.chatTitleField];
    
    // Messages container
    self.chatScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 60, chatArea.bounds.size.width, chatArea.bounds.size.height - 120)];
    self.chatScrollView.hasVerticalScroller = YES;
    self.chatScrollView.autohidesScrollers = YES;
    
    self.chatContainer = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, chatArea.bounds.size.width, 400)];
    self.chatScrollView.documentView = self.chatContainer;
    [chatArea addSubview:self.chatScrollView];
    
    [self layoutMessages];
    
    // Message input area
    NSView *inputArea = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, chatArea.bounds.size.width, 60)];
    inputArea.wantsLayer = YES;
    inputArea.layer.backgroundColor = [[NSColor colorWithWhite:0.97 alpha:1.0] CGColor];
    [chatArea addSubview:inputArea];
    
    self.messageField = [[NSTextField alloc] initWithFrame:NSMakeRect(15, 15, chatArea.bounds.size.width - 100, 30)];
    self.messageField.placeholderString = @"Type a message...";
    self.messageField.bezeled = YES;
    self.messageField.bezelStyle = NSTextFieldRoundedBezel;
    self.messageField.editable = YES;
    self.messageField.selectable = YES;
    [inputArea addSubview:self.messageField];
    
    NSButton *sendBtn = [[NSButton alloc] initWithFrame:NSMakeRect(chatArea.bounds.size.width - 75, 15, 60, 30)];
    sendBtn.title = @"Send";
    sendBtn.bezelStyle = NSBezelStyleRounded;
    sendBtn.target = self;
    sendBtn.action = @selector(sendButtonClicked:);
    [inputArea addSubview:sendBtn];
    
    [self.messagesWindow makeKeyAndOrderFront:nil];
}

- (void)addContact:(id)sender {
    self.addContactWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 350, 200)
                                                        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                          backing:NSBackingStoreBuffered
                                                            defer:NO];
    [self.addContactWindow setTitle:@"Add Contact"];
    [self.addContactWindow center];
    
    NSView *content = [[NSView alloc] initWithFrame:self.addContactWindow.contentView.bounds];
    content.wantsLayer = YES;
    content.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    [self.addContactWindow setContentView:content];
    
    // Name field
    NSTextField *nameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 145, 80, 22)];
    nameLabel.stringValue = @"Name:";
    nameLabel.bezeled = NO;
    nameLabel.editable = NO;
    nameLabel.drawsBackground = NO;
    [content addSubview:nameLabel];
    
    self.addNameField = [[NSTextField alloc] initWithFrame:NSMakeRect(100, 143, 230, 26)];
    self.addNameField.placeholderString = @"John Doe";
    [content addSubview:self.addNameField];
    
    // Phone field
    NSTextField *phoneLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 105, 80, 22)];
    phoneLabel.stringValue = @"Phone:";
    phoneLabel.bezeled = NO;
    phoneLabel.editable = NO;
    phoneLabel.drawsBackground = NO;
    [content addSubview:phoneLabel];
    
    self.addPhoneField = [[NSTextField alloc] initWithFrame:NSMakeRect(100, 103, 230, 26)];
    self.addPhoneField.placeholderString = @"+1 (555) 123-4567";
    [content addSubview:self.addPhoneField];
    
    // Save button
    NSButton *saveBtn = [[NSButton alloc] initWithFrame:NSMakeRect(220, 20, 110, 35)];
    saveBtn.title = @"Add Contact";
    saveBtn.bezelStyle = NSBezelStyleRounded;
    saveBtn.keyEquivalent = @"\r";
    saveBtn.target = self;
    saveBtn.action = @selector(saveNewContact:);
    [content addSubview:saveBtn];
    
    // Cancel button
    NSButton *cancelBtn = [[NSButton alloc] initWithFrame:NSMakeRect(110, 20, 100, 35)];
    cancelBtn.title = @"Cancel";
    cancelBtn.bezelStyle = NSBezelStyleRounded;
    cancelBtn.target = self;
    cancelBtn.action = @selector(cancelAddContact:);
    [content addSubview:cancelBtn];
    
    [self.addContactWindow makeKeyAndOrderFront:nil];
}

- (void)cancelAddContact:(id)sender {
    [self.addContactWindow close];
    self.addContactWindow = nil;
}

- (void)saveNewContact:(NSButton *)sender {
    NSString *name = self.addNameField.stringValue;
    NSString *phone = self.addPhoneField.stringValue;
    
    if (name.length == 0 || phone.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Missing Information";
        alert.informativeText = @"Please enter both name and phone number.";
        [alert runModal];
        return;
    }
    
    NSDictionary *newContact = @{
        @"name": name,
        @"phone": phone,
        @"avatar": @"👤",
        @"status": @"available"
    };
    
    [self.contacts addObject:newContact];
    [self saveContacts];
    [self.contactsTable reloadData];
    
    [self.addContactWindow close];
    self.addContactWindow = nil;
}

- (void)newConversation:(id)sender {
    if (self.contacts.count == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"No Contacts";
        alert.informativeText = @"Add a contact first to start a conversation.";
        [alert runModal];
        return;
    }
    
    // Select first contact and focus input
    [self.contactsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [self.messagesWindow makeFirstResponder:self.messageField];
}

- (void)layoutMessages {
    // Remove old subviews
    for (NSView *subview in [self.chatContainer.subviews copy]) {
        [subview removeFromSuperview];
    }
    
    CGFloat yPos = 20;
    CGFloat maxWidth = self.chatContainer.bounds.size.width - 100;
    
    for (NSDictionary *msg in self.currentMessages) {
        BOOL isMe = [msg[@"sender"] isEqualToString:@"me"];
        NSString *text = msg[@"text"];
        
        // Calculate bubble size
        NSDictionary *attrs = @{NSFontAttributeName: [NSFont systemFontOfSize:13]};
        NSSize textSize = [text sizeWithAttributes:attrs];
        CGFloat bubbleWidth = MIN(textSize.width + 24, maxWidth);
        CGFloat bubbleHeight = 36;
        
        CGFloat xPos = isMe ? (self.chatContainer.bounds.size.width - bubbleWidth - 20) : 20;
        
        // Bubble background
        NSView *bubble = [[NSView alloc] initWithFrame:NSMakeRect(xPos, yPos, bubbleWidth, bubbleHeight)];
        bubble.wantsLayer = YES;
        bubble.layer.cornerRadius = 16;
        bubble.layer.backgroundColor = isMe ?
            [[NSColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0] CGColor] :
            [[NSColor colorWithWhite:0.9 alpha:1.0] CGColor];
        [self.chatContainer addSubview:bubble];
        
        // Message text
        NSTextField *msgLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 8, bubbleWidth - 24, 20)];
        msgLabel.stringValue = text;
        msgLabel.font = [NSFont systemFontOfSize:13];
        msgLabel.textColor = isMe ? [NSColor whiteColor] : [NSColor blackColor];
        msgLabel.bezeled = NO;
        msgLabel.editable = NO;
        msgLabel.drawsBackground = NO;
        [bubble addSubview:msgLabel];
        
        // Time label
        NSTextField *timeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(xPos, yPos - 16, bubbleWidth, 14)];
        timeLabel.stringValue = msg[@"time"];
        timeLabel.font = [NSFont systemFontOfSize:10];
        timeLabel.textColor = [NSColor grayColor];
        timeLabel.alignment = isMe ? NSTextAlignmentRight : NSTextAlignmentLeft;
        timeLabel.bezeled = NO;
        timeLabel.editable = NO;
        timeLabel.drawsBackground = NO;
        [self.chatContainer addSubview:timeLabel];
        
        yPos += bubbleHeight + 25;
    }
    
    // Resize container
    CGFloat newHeight = MAX(yPos + 20, self.chatScrollView.bounds.size.height);
    [self.chatContainer setFrameSize:NSMakeSize(self.chatContainer.bounds.size.width, newHeight)];
}

- (void)sendButtonClicked:(id)sender {
    [self doSendMessage];
}

- (void)doSendMessage {
    // Make sure we have a valid message field
    if (!self.messageField) {
        return;
    }
    
    // End editing to commit any in-progress text
    [self.messagesWindow makeFirstResponder:nil];
    
    // Get the text after ending editing
    NSString *text = [self.messageField.stringValue copy];
    
    if (!text || text.length == 0) {
        return;
    }
    
    // Trim whitespace
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) return;
    
    if (self.selectedContact < 0 || self.selectedContact >= (NSInteger)self.contacts.count) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"No Conversation Selected";
        alert.informativeText = @"Please select a contact from the list first.";
        [alert runModal];
        return;
    }
    
    // Clear field immediately
    self.messageField.stringValue = @"";
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"h:mm a";
    NSString *time = [df stringFromDate:[NSDate date]];
    
    NSDictionary *newMessage = @{@"sender": @"me", @"text": text, @"time": time};
    [self.currentMessages addObject:newMessage];
    
    // Save conversation
    NSDictionary *contact = self.contacts[self.selectedContact];
    NSString *contactId = contact[@"phone"];
    if (contactId) {
        self.conversations[contactId] = [self.currentMessages copy];
        [self saveContacts];
    }
    
    [self layoutMessages];
    
    // Scroll to bottom
    NSPoint bottomPoint = NSMakePoint(0, 0);
    [self.chatScrollView.documentView scrollPoint:bottomPoint];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.contacts.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 250, 60)];
    
    NSDictionary *contact = self.contacts[row];
    
    // Avatar
    NSTextField *avatar = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 12, 36, 36)];
    avatar.stringValue = contact[@"avatar"];
    avatar.font = [NSFont systemFontOfSize:24];
    avatar.alignment = NSTextAlignmentCenter;
    avatar.bezeled = NO;
    avatar.editable = NO;
    avatar.drawsBackground = NO;
    [cell addSubview:avatar];
    
    // Name
    NSTextField *name = [[NSTextField alloc] initWithFrame:NSMakeRect(55, 30, 180, 20)];
    name.stringValue = contact[@"name"];
    name.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    name.bezeled = NO;
    name.editable = NO;
    name.drawsBackground = NO;
    [cell addSubview:name];
    
    // Status
    NSTextField *status = [[NSTextField alloc] initWithFrame:NSMakeRect(55, 12, 180, 16)];
    status.stringValue = contact[@"status"];
    status.font = [NSFont systemFontOfSize:11];
    status.textColor = [contact[@"status"] isEqualToString:@"online"] ?
        [NSColor colorWithRed:0.2 green:0.7 blue:0.3 alpha:1.0] : [NSColor grayColor];
    status.bezeled = NO;
    status.editable = NO;
    status.drawsBackground = NO;
    [cell addSubview:status];
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    self.selectedContact = self.contactsTable.selectedRow;
    
    if (self.selectedContact >= 0 && self.selectedContact < (NSInteger)self.contacts.count) {
        NSDictionary *contact = self.contacts[self.selectedContact];
        self.chatTitleField.stringValue = [NSString stringWithFormat:@"%@ • %@", contact[@"name"], contact[@"phone"]];
        
        // Load conversation for this contact
        NSString *contactId = contact[@"phone"];
        NSArray *savedMessages = self.conversations[contactId];
        
        [self.currentMessages removeAllObjects];
        if (savedMessages) {
            [self.currentMessages addObjectsFromArray:savedMessages];
        }
        
        [self layoutMessages];
    }
}

@end
