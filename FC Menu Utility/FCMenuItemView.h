#import <Cocoa/Cocoa.h>

@interface FCMenuItemView : NSView <NSMenuDelegate, NSDraggingDestination> {
    NSImage * icon;
    NSImage * altIcon;
    NSString * launcherPath;
    NSStatusItem * statusItem;
    NSMenu * layoutMenu;
    NSMenu * controlMenu;
    BOOL isStatusItemActive;
}

- (NSMenu *) layoutMenu;
- (NSMenu *) controlMenu;
- (NSStatusItem *) statusItem;
- (void) setStatusItem:(NSStatusItem *)aStatusItem;
- (NSString *) launcherPath;
- (void) setLauncherPath:(NSString *)aLauncherPath;

@end
