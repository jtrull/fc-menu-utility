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

- (id) initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        icon = loadImageFromBundle([NSBundle mainBundle], IconFile);
        altIcon = loadImageFromBundle([NSBundle mainBundle], AltIconFile);
        
        layoutMenu = [[NSMenu alloc] init];
        controlMenu = [[NSMenu alloc] init];
        isStatusItemActive = NO;

        statusItem = nil;
        menuItemController = nil;

        [self registerForDraggedTypes:[NSArray arrayWithObject: NSFilenamesPboardType]];
    }

    return self;
}

- (void) setStatusItem:(NSStatusItem *) aStatusItem {
    statusItem = aStatusItem;
    [statusItem setView:self];
}

- (void) setMenuItemController:(FCMenuItemController *) aMenuItemController {
    menuItemController = aMenuItemController;
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
    [self popUpMenu:[menuItemController layoutMenu]];
}

- (void) popUpControlMenu {
    [self popUpMenu:[menuItemController controlMenu]];
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

- (NSDragOperation) draggingEntered:(id<NSDraggingInfo>) sender {
    [self setStatusItemActive];
    
    return NSDragOperationGeneric;
}

- (BOOL) prepareForDragOperation:(id<NSDraggingInfo>) sender {
    return YES;
}

- (BOOL) performDragOperation:(id<NSDraggingInfo>) sender {
    NSPasteboard * pboard = [sender draggingPasteboard];
    [menuItemController handleItemsDroppedFromPasteboard:pboard];
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
