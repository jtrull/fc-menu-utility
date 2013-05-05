#import <Cocoa/Cocoa.h>
#import "FCMenuItemDelegate.h"

@interface FCMenuItemView : NSView <NSMenuDelegate, NSDraggingDestination> {
    NSImage * icon;
    NSImage * altIcon;
    NSStatusItem * statusItem;
    NSMenu * layoutMenu;
    NSMenu * controlMenu;
    BOOL isStatusItemActive;
    FCMenuItemDelegate * menuItemDelegate;
}

- (void) setMenuItemDelegate:(FCMenuItemDelegate *) aMenuItemDelegate;
- (void) setStatusItem:(NSStatusItem *) aStatusItem;

@end
