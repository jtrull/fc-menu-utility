//
//  LoginItem.m
//  FC Menu Utility
//
//  Created by Jonathan Trull on 5/14/13.
//  Copyright (c) 2013 Jonathan Trull. All rights reserved.
//

#import <SecurityFoundation/SFAuthorization.h>
#import "LoginItem.h"

static void installLoginItem(LSSharedFileListRef globalLoginItems,
                             NSURL * itemUrl) {
    LSSharedFileListItemRef loginItem =
        LSSharedFileListInsertItemURL(globalLoginItems,
                                      kLSSharedFileListItemLast,
                                      NULL, NULL,
                                      (CFURLRef) itemUrl,
                                      NULL, NULL);
    if (loginItem) {
        CFRelease(loginItem);
    } else {
        NSLog(@"Could not insert global login item.");
    }
}

static LSSharedFileListRef getGlobalLoginItems() {
    LSSharedFileListRef globalLoginItems =
        LSSharedFileListCreate(NULL, kLSSharedFileListGlobalLoginItems, NULL);
    if (!globalLoginItems) {
        NSLog(@"Could not get global login items.");
    }

    // Authorize user.
    SFAuthorization * auth = [SFAuthorization authorization];
    NSError * error = nil;
    if (![auth obtainWithRight:"system.global-login-items."
                         flags:kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights
                         error:&error]) {
        NSLog(@"Could not create auth ref. Status code: %ld", (long)[error code]);
        return NULL;
    }
    
    OSStatus status = LSSharedFileListSetAuthorization(globalLoginItems,
                                                       [auth authorizationRef]);
    if (status == noErr) {
        return globalLoginItems;
    } else {
        return NULL;
    }
}

static LSSharedFileListItemRef findLoginItem(LSSharedFileListRef globalLoginItems, NSURL * thisUrl) {
    // Check if login item is already present.
    NSString * thisPath = [thisUrl path];
    LSSharedFileListItemRef foundItem = NULL;
	UInt32 seedValue;
    
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(globalLoginItems, &seedValue);
    if (!loginItemsArray) {
        NSLog(@"Could not snapshot global login items list.");
        return NULL;
    }
    
    CFIndex loginItemsCount = CFArrayGetCount(loginItemsArray);
    for (CFIndex i = 0; i < loginItemsCount; i++) {
        LSSharedFileListItemRef itemRef =
            (LSSharedFileListItemRef) CFArrayGetValueAtIndex(loginItemsArray, i);
        NSURL * itemUrl = NULL;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *) &itemUrl, NULL) == noErr) {
            if (itemUrl != NULL) {
                BOOL found = [[itemUrl path] hasPrefix:thisPath];
                [itemUrl release];
                if (found) {
                    foundItem = itemRef;
                    break;
                }
            }
		}
    }
	
    if (foundItem) {
        CFRetain(foundItem);
    }
    CFRelease(loginItemsArray);
	return foundItem;
}

int installLoginItemIfNeeded() {
    // App bundle URL
    NSURL * appUrl = [[NSBundle mainBundle] bundleURL];
    
    // Get global login items.
    LSSharedFileListRef globalLoginItems = getGlobalLoginItems();
    if (!globalLoginItems) {
        return -2;
    }
    
    LSSharedFileListItemRef loginItem = findLoginItem(globalLoginItems, appUrl);
    
    if (loginItem) {
        CFRelease(loginItem);
    } else {
        installLoginItem(globalLoginItems, appUrl);
    }
    
    CFRelease(globalLoginItems);
    return 0;
}

int removeLoginItemIfPresent() {
    // App bundle URL
    NSURL * appUrl = [[NSBundle mainBundle] bundleURL];
    
    // Get global login items.
    LSSharedFileListRef globalLoginItems = getGlobalLoginItems();
    if (!globalLoginItems) {
        return -2;
    }
    
    LSSharedFileListItemRef loginItem = findLoginItem(globalLoginItems, appUrl);
    
    if (loginItem) {
        LSSharedFileListItemRemove(globalLoginItems, loginItem);
        CFRelease(loginItem);
    }

    CFRelease(globalLoginItems);
    return 0;
}
