#import "FCAppDelegate.h"
#import "FCMenuItemView.h"
#import "FCMenuItemController.h"
#import <Sparkle/Sparkle.h>

@implementation FCAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize Sparkle updater.
    [SUUpdater sharedUpdater];

    NSStatusBar * statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];

    FCMenuItemView * view = [[FCMenuItemView alloc] init];
    FCMenuItemController * menuController = [[FCMenuItemController alloc] init];

    [view setMenuItemController:menuController];
    [view setStatusItem:statusItem];
}

@end
