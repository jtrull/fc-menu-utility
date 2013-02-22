#import <Cocoa/Cocoa.h>

@interface FCMenuItemView : NSView <NSMenuDelegate, NSDraggingDestination> {
    NSImage * defaultIcon;
    NSImage * defaultAltIcon;
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
- (NSImage *) icon;
- (void) setIcon:(NSImage *)anImage;
- (NSImage *) altIcon;
- (void) setAltIcon:(NSImage *)anImage;
- (NSString *) launcherPath;
- (void) setLauncherPath:(NSString *)aLauncherPath;

@end
