#import <Cocoa/Cocoa.h>
#import "FCMenuItemController.h"

@interface FCMenuItemView : NSView <NSMenuDelegate, NSDraggingDestination> {
    NSImage * icon;
    NSImage * altIcon;
    NSStatusItem * statusItem;
    NSMenu * layoutMenu;
    NSMenu * controlMenu;
    BOOL isStatusItemActive;
    FCMenuItemController * menuItemController;
}

- (void) setMenuItemController:(FCMenuItemController *) aMenuItemController;
- (void) setStatusItem:(NSStatusItem *) aStatusItem;

@end
