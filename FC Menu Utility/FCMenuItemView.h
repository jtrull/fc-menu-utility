#import <Cocoa/Cocoa.h>
#import "FCMenuItemDelegate.h"

@interface FCMenuItemView : NSView <NSMenuDelegate, NSDraggingDestination> {
    NSImage * icon;
    NSImage * altIcon;
    NSString * launcherPath;
    NSStatusItem * statusItem;
    NSMenu * layoutMenu;
    NSMenu * controlMenu;
    BOOL isStatusItemActive;
}

@property FCMenuItemDelegate * menuItemDelegate;

- (void) setStatusItem:(NSStatusItem *) aStatusItem;

@end
