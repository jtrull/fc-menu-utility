#import "FCAppDelegate.h"
#import "FCMenuItemView.h"
#import "FCMenuItemDelegate.h"
#import <Sparkle/Sparkle.h>

@implementation FCAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize Sparkle updater.
    [SUUpdater sharedUpdater];

    NSStatusBar * statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    FCMenuItemView * view = [[FCMenuItemView alloc] init];
    [view setMenuItemDelegate:[[FCMenuItemDelegate alloc] init]];
    [view setStatusItem:statusItem];
}

@end
