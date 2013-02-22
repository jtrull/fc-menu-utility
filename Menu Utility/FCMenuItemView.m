#import "FCMenuItemView.h"
#import "IconLoader.h"

static CGFloat const STATUS_ICON_ORIGIN_X = 6.0;
static CGFloat const STATUS_ICON_ORIGIN_Y = 3.0;

@implementation FCMenuItemView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        defaultIcon = loadImageFromBundle([NSBundle mainBundle], IconFile);
        defaultAltIcon = loadImageFromBundle([NSBundle mainBundle], AltIconFile);
        
        layoutMenu = [[NSMenu alloc] init];
        controlMenu = [[NSMenu alloc] init];
        isStatusItemActive = NO;
        icon = nil;
        altIcon = nil;

        launcherPath = nil;
    }

    return self;
}

- (NSStatusItem *)statusItem {
    return statusItem;
}

- (void) setStatusItem:(NSStatusItem *)aStatusItem {
    statusItem = aStatusItem;
    [statusItem setView:self];
}

- (NSMenu *)layoutMenu {
    return layoutMenu;
}

- (NSMenu *)controlMenu {
    return controlMenu;
}

- (NSImage *)icon {
    if (icon) {
        return icon;
    } else {
        return defaultIcon;
    }
}

- (void) setIcon:(NSImage *)anImage {
    icon = anImage;
    [self setNeedsDisplay:YES];
}

- (NSImage *)altIcon {
    if (altIcon) {
        return altIcon;
    } else {
        return defaultAltIcon;
    }
}

- (void)setAltIcon:(NSImage *)anImage {
    altIcon = anImage;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
    if ([event modifierFlags] & NSAlternateKeyMask) {
        [self popUpMenu:controlMenu];
    } else {
        [self popUpMenu:layoutMenu];
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    [self popUpMenu:controlMenu];
}

- (void)popUpMenu:(NSMenu *)aMenu {
    [aMenu setDelegate:self];
    [statusItem popUpStatusItemMenu:aMenu];
}

- (void)menuWillOpen:(NSMenu *)aMenu {
    [self setStatusItemActive:YES];
}

- (void)menuDidClose:(NSMenu *)aMenu {
    [aMenu setDelegate:nil];
    [self setStatusItemActive:NO];
}

- (void)drawRect:(NSRect)dirtyRect {
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isStatusItemActive];

    NSImage * imageToDraw = [self icon];
    if (isStatusItemActive) {
        imageToDraw = [self altIcon];
    }
    
    [imageToDraw drawAtPoint:NSMakePoint(STATUS_ICON_ORIGIN_X, STATUS_ICON_ORIGIN_Y)
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
}

- (NSString *)launcherPath {
    return launcherPath;
}

- (void)setLauncherPath:(NSString *)aLauncherPath {
    launcherPath = aLauncherPath;
    if (launcherPath) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    } else {
        [self unregisterDraggedTypes];
    }
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    [self setStatusItemActive:YES];
    
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard * pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject: NSFilenamesPboardType]) {
        NSArray * files = [pboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray * urls = [NSMutableArray arrayWithCapacity:[files count]];
        for (NSString * path in files) {
            [urls addObject:[[NSURL alloc] initFileURLWithPath:path]];
        }
        
        FSRef appRef;
        FSPathMakeRef((const UInt8 *)[launcherPath fileSystemRepresentation], &appRef, NULL);

        LSApplicationParameters appParams = {0};
        appParams.application = &appRef;
        appParams.flags = kLSLaunchAndDisplayErrors | kLSLaunchAsync | kLSLaunchNewInstance;
        
        LSOpenURLsWithRole((__bridge CFArrayRef)(urls),
                           kLSRolesAll, NULL, &appParams, NULL, 0);
    }
    
    return YES;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self setStatusItemActive:NO];
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    // Blink menu item.
    [self performSelector:@selector(setStatusItemActive:)
               withObject:[NSNumber numberWithBool:NO]
               afterDelay:0.0f];
    [self performSelector:@selector(setStatusItemActive:)
               withObject:[NSNumber numberWithBool:YES]
               afterDelay:0.1];
    [self performSelector:@selector(setStatusItemActive:)
               withObject:[NSNumber numberWithBool:NO]
               afterDelay:0.2f];
}

- (void)setStatusItemActive:(BOOL)active {
    isStatusItemActive = active;
    [self setNeedsDisplay:YES];
}

@end
