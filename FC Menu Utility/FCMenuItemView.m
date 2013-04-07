#import "FCMenuItemView.h"

static CGFloat const STATUS_ICON_ORIGIN_X = 6.0;
static CGFloat const STATUS_ICON_ORIGIN_Y = 3.0;

static NSString * const IconFile      = @"icon";
static NSString * const AltIconFile   = @"alt-icon";
static NSString * const IconExtension = @"png";

NSImage * loadImageFromBundle(NSBundle * aBundle, NSString * imageName) {
    if ([aBundle respondsToSelector:@selector(imageForResource:)]) {
        return [aBundle imageForResource:imageName];
    } else {
        NSString * imageFileName = [imageName stringByAppendingPathExtension:IconExtension];
        return [[NSImage alloc] initWithContentsOfFile:
                [[aBundle resourcePath] stringByAppendingPathComponent:imageFileName]];
    }
}

@implementation FCMenuItemView

@synthesize menuItemDelegate;

- (id) initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        icon = loadImageFromBundle([NSBundle mainBundle], IconFile);
        altIcon = loadImageFromBundle([NSBundle mainBundle], AltIconFile);
        
        layoutMenu = [[NSMenu alloc] init];
        controlMenu = [[NSMenu alloc] init];
        isStatusItemActive = NO;

        launcherPath = nil;
        statusItem = nil;
    }

    return self;
}

- (void) setStatusItem:(NSStatusItem *) aStatusItem {
    statusItem = aStatusItem;
    [statusItem setView:self];
}

- (void) mouseDown:(NSEvent *)event {
    if ([event modifierFlags] & NSAlternateKeyMask) {
        [self popUpControlMenu];
    } else {
        [self popUpLayoutMenu];
    }
}

- (void) rightMouseDown:(NSEvent *)event {
    [self popUpControlMenu];
}

- (void) popUpLayoutMenu {
    if (menuItemDelegate && [[layoutMenu itemArray] count] == 0) {
        [menuItemDelegate populateMainMenu:layoutMenu];
    }
    [self popUpMenu:layoutMenu];
}

- (void) popUpControlMenu {
    if (menuItemDelegate && [[controlMenu itemArray] count] == 0) {
        [menuItemDelegate populateControlMenu:controlMenu];
    }
    [self popUpMenu:controlMenu];
}

- (void) popUpMenu:(NSMenu *)aMenu {
    [aMenu setDelegate:self];
    [statusItem popUpStatusItemMenu:aMenu];
}

- (void) menuWillOpen:(NSMenu *)aMenu {
    [self setStatusItemActive];
}

- (void) menuDidClose:(NSMenu *)aMenu {
    [aMenu setDelegate:nil];
    [self setStatusItemInactive];
}

- (void) drawRect:(NSRect) dirtyRect {
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isStatusItemActive];

    NSImage * imageToDraw = icon;
    if (isStatusItemActive) {
        imageToDraw = altIcon;
    }
    
    [imageToDraw drawAtPoint:NSMakePoint(STATUS_ICON_ORIGIN_X, STATUS_ICON_ORIGIN_Y)
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
}

- (NSString *) launcherPath {
    return launcherPath;
}

- (void) setLauncherPath:(NSString *) aLauncherPath {
    launcherPath = aLauncherPath;
    if (launcherPath) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    } else {
        [self unregisterDraggedTypes];
    }
}

- (NSDragOperation) draggingEntered:(id<NSDraggingInfo>) sender {
    [self setStatusItemActive];
    
    return NSDragOperationGeneric;
}

- (BOOL) prepareForDragOperation:(id<NSDraggingInfo>) sender {
    return YES;
}

- (BOOL) performDragOperation:(id<NSDraggingInfo>) sender {
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

- (void) draggingExited:(id<NSDraggingInfo>) sender {
    [self setStatusItemInactive];
}

- (void) concludeDragOperation:(id<NSDraggingInfo>) sender {
    // Blink menu item.
    [self performSelector:@selector(setStatusItemInactive)
               withObject:nil
               afterDelay:0.1f];
    [self performSelector:@selector(setStatusItemActive)
               withObject:nil
               afterDelay:0.2f];
    [self performSelector:@selector(setStatusItemInactive)
               withObject:nil
               afterDelay:0.3f];
}

- (void) setStatusItemActive {
    isStatusItemActive = YES;
    [self setNeedsDisplay:YES];
}

- (void) setStatusItemInactive {
    isStatusItemActive = NO;
    [self setNeedsDisplay:YES];
}

@end
