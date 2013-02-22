#import "FCAppDelegate.h"
#import "FCMenuItemView.h"

@implementation FCAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSStatusBar * statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    FCMenuItemView * view = [[FCMenuItemView alloc] init];
    [view setStatusItem:statusItem];

    controller = [[FCMenuItemController alloc] initWithMenuItemView:view];
    [controller start];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
    [controller stop];
    controller = nil;
}

@end
