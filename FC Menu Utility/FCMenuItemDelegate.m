#import "FCMenuItemDelegate.h"
#import <Sparkle/Sparkle.h>

static NSString * const LayoutPath          = @"Layout";
static NSString * const LauncherPath        = @"Launcher.app";
static NSString * const UninstallerPath     = @"Uninstaller.app";

@implementation FCMenuItemDelegate
- (void) populateMainMenu:(NSMenu *) aMenu {
    [self addAppVersionToMenu:aMenu];
    [self addItemsToMenu:aMenu
          withLayoutPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LayoutPath]];
}

- (void) populateControlMenu:(NSMenu *) aMenu {
    NSMenuItem * item = [aMenu addItemWithTitle:@"Check for Updates..."
                                         action:@selector(checkForUpdates:)
                                  keyEquivalent:@""];
    [item setTarget:[SUUpdater sharedUpdater]];
    
    [aMenu addItem:[NSMenuItem separatorItem]];
    
    item = [aMenu addItemWithTitle:@"Uninstall Menu Utility..."
                            action:@selector(uninstall)
                     keyEquivalent:@""];
    [item setTarget:self];
    
    [aMenu addItem:[NSMenuItem separatorItem]];
    
    item = [aMenu addItemWithTitle:@"Quit Menu Utility"
                            action:@selector(terminate:)
                     keyEquivalent:@""];
    [item setTarget:NSApp];
}

- (void) handleItemsDroppedFromPasteboard:(NSPasteboard *) aPasteboard {
    if ([[aPasteboard types] containsObject:NSFilenamesPboardType]) {
        NSString * launcherPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LauncherPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:launcherPath]) {
            NSAlert * alert = [[NSAlert alloc] init];
            [alert setMessageText:@"No launcher application configured."];
            [alert runModal];
            return;
        }

        FSRef appRef;
        FSPathMakeRef((const UInt8 *)[launcherPath fileSystemRepresentation], &appRef, NULL);
        
        NSArray * files = [aPasteboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray * urls = [NSMutableArray arrayWithCapacity:[files count]];
        for (NSString * path in files) {
            [urls addObject:[[NSURL alloc] initFileURLWithPath:path]];
        }

        LSApplicationParameters appParams = {0};
        appParams.application = &appRef;
        appParams.flags = kLSLaunchAndDisplayErrors | kLSLaunchAsync | kLSLaunchNewInstance;
        
        LSOpenURLsWithRole((__bridge CFArrayRef)(urls),
                           kLSRolesAll, NULL, &appParams, NULL, 0);
    }
}

- (void) addAppVersionToMenu:(NSMenu *) aMenu {
    NSString * name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString * bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * displayVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FCDisplayVersion"];
    
    if (displayVersion) {
        [aMenu addItemWithTitle:displayVersion
                         action:nil
                  keyEquivalent:@""];
        [aMenu addItem:[NSMenuItem separatorItem]];
    } else if (name && bundleVersion) {
        [aMenu addItemWithTitle:[NSString stringWithFormat:@"%@ - v%@", name, bundleVersion]
                         action:nil
                  keyEquivalent:@""];
        [aMenu addItem:[NSMenuItem separatorItem]];
    }
}

- (void) addItemsToMenu:(NSMenu *)aMenu withLayoutPath:(NSString *)aPath {
    NSFileManager * manager = [NSFileManager defaultManager];
    
    uint groupIndex = 1;
    while (TRUE) {
        NSString * groupString = [NSString stringWithFormat:@"%d", groupIndex];
        NSString * groupPath = [aPath stringByAppendingPathComponent:groupString];
        
        BOOL isDirectory;
        if (![manager fileExistsAtPath:groupPath isDirectory:&isDirectory]) {
            break;
        }
        if (!isDirectory) {
            break;
        }
        
        [self addItemsToMenu:aMenu withLayoutPath:groupPath];
        [aMenu addItem:[NSMenuItem separatorItem]];
        groupIndex++;
    }
    
    if (groupIndex > 1) {
        // remove final separator
        [aMenu removeItemAtIndex:([aMenu numberOfItems] - 1)];
        return;
    }
    
    NSArray * files = [manager contentsOfDirectoryAtPath:aPath error:nil];
    files = [files sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString * file in files) {
        NSString * filePath = [aPath stringByAppendingPathComponent:file];
        
        LSItemInfoRecord itemInfo;
        LSCopyItemInfoForURL((__bridge CFURLRef)([NSURL fileURLWithPath:filePath]),
                             kLSRequestAllFlags, &itemInfo);
        
        if (itemInfo.flags & kLSItemInfoIsInvisible) {
            continue;
        }
        
        NSString * name = [file stringByDeletingPathExtension];
        NSImage * image = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
        
        NSMenuItem * menuItem = [aMenu addItemWithTitle:name
                                                 action:@selector(activateItem:)
                                          keyEquivalent:@""];
        [menuItem setTarget:self];
        [menuItem setRepresentedObject:filePath];
        [menuItem setImage:image];
        
        BOOL isDirectory;
        [manager fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (isDirectory) {
            if (itemInfo.flags & kLSItemInfoIsPackage) {
                continue;
            } else {
                [menuItem setAction:nil];
            }
            
            NSMenu * submenu = [[NSMenu alloc] init];
            [self addItemsToMenu:submenu withLayoutPath:filePath];
            if ([submenu numberOfItems] > 0) {
                [menuItem setSubmenu:submenu];
            }
        }
    }
}

- (void) activateItem:(id)sender {
    NSString * filePath = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openFile:filePath];
}

- (void) uninstall {
    NSAlert * alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:@"Uninstall Menu Utility?"];
    [alert setInformativeText:@"Are you sure you want to uninstall Menu Utility?"];
    [alert addButtonWithTitle:@"Uninstall"];
    [alert addButtonWithTitle:@"Cancel"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        NSURL * uninstallerUrl = [[[NSBundle mainBundle] resourceURL]                                  URLByAppendingPathComponent:UninstallerPath];
        NSError * error;
        if (![[NSWorkspace sharedWorkspace] launchApplicationAtURL:uninstallerUrl
                                                           options:NSWorkspaceLaunchWithoutAddingToRecents
                                                     configuration:nil
                                                             error:&error]) {
            NSString * errorMsg = [NSString stringWithFormat:@"Could not launch the uninstaller. The error was: %@", [error localizedDescription]];
            alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:@"Could not uninstall"];
            [alert setInformativeText:errorMsg];
            [alert runModal];
        }
    }
}

@end
