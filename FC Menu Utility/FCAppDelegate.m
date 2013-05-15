#import "FCAppDelegate.h"
#import "FCMenuItemView.h"
#import "FCMenuItemDelegate.h"
#import <Sparkle/Sparkle.h>
#import <SecurityFoundation/SFAuthorization.h>

static void installLoginItem(LSSharedFileListRef globalLoginItems,
                             NSURL * itemUrl) {
    // Authorize user.
    SFAuthorization * auth = [SFAuthorization authorization];
    NSError * error = nil;
    if (![auth obtainWithRight:"system.global-login-items."
                         flags:kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights
                         error:&error]) {
        NSLog(@"Could not create auth ref. Status code: %ld", (long)[error code]);
        return;
    }

    OSStatus status = LSSharedFileListSetAuthorization(globalLoginItems,
                                                       [auth authorizationRef]);
    if (status == noErr) {
        LSSharedFileListItemRef loginItem =
            LSSharedFileListInsertItemURL(globalLoginItems,
                                          kLSSharedFileListItemLast,
                                          NULL, NULL,
                                          (__bridge CFURLRef)(itemUrl),
                                          NULL, NULL);
        if (loginItem) {
            CFRelease(loginItem);
        } else {
            NSLog(@"Could not insert global login item.");
        }
    } else {
        NSLog(@"Could not set shared file list auth. Status code: %d", status);
    }

    [auth invalidateCredentials];
}

static BOOL checkLoginItem(LSSharedFileListRef globalLoginItems,
                           NSURL * thisUrl) {
    // Check if login item is already present.
    NSString * thisPath = [thisUrl path];
	BOOL found = NO;
	UInt32 seedValue;
    
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(globalLoginItems, &seedValue);
    if (!loginItemsArray) {
        NSLog(@"Could not snapshot global login items list.");
        return NO;
    }

    CFIndex loginItemsCount = CFArrayGetCount(loginItemsArray);
    for (CFIndex i = 0; i < loginItemsCount; i++) {
        LSSharedFileListItemRef itemRef =
            (LSSharedFileListItemRef) CFArrayGetValueAtIndex(loginItemsArray, i);
        CFURLRef itemUrl = NULL;
		if (LSSharedFileListItemResolve(itemRef, 0, &itemUrl, NULL) == noErr) {
            if (itemUrl != NULL) {
                found = [[(__bridge NSURL *)itemUrl path] hasPrefix:thisPath];
                CFRelease(itemUrl);
                if (found) {
                    break;
                }
            }
		}
    }
	
    CFRelease(loginItemsArray);
	return found;
}

static void installLoginItemIfNeeded() {
    // App bundle URL
    NSURL * appUrl = [[NSBundle mainBundle] bundleURL];

    // Get global login items.
    LSSharedFileListRef globalLoginItems =
    LSSharedFileListCreate(NULL, kLSSharedFileListGlobalLoginItems, NULL);
    if (!globalLoginItems) {
        NSLog(@"Could not get global login items.");
        return;
    }
    
    if (!checkLoginItem(globalLoginItems, appUrl)) {
        installLoginItem(globalLoginItems, appUrl);
    }
    
    CFRelease(globalLoginItems);
}

@implementation FCAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize Sparkle updater.
    [SUUpdater sharedUpdater];

    NSStatusBar * statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    FCMenuItemView * view = [[FCMenuItemView alloc] init];
    [view setMenuItemDelegate:[[FCMenuItemDelegate alloc] init]];
    [view setStatusItem:statusItem];
    
//    installLoginItemIfNeeded();
}

@end
