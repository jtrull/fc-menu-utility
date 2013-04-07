#import "FCAppDelegate.h"
#import "FCMenuItemView.h"
#import <Sparkle/Sparkle.h>

@implementation FCAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize Sparkle updater.
    [SUUpdater sharedUpdater];

    NSStatusBar * statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    FCMenuItemView * view = [[FCMenuItemView alloc] init];
    [view setStatusItem:statusItem];

    controller = [[FCMenuItemDelegate alloc] initWithMenuItemView:view];
    [controller start];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
    [controller stop];
    controller = nil;
}

@end
