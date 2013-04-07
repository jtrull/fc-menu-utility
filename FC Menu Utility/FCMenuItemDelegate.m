#import "FCMenuItemDelegate.h"
#import <Sparkle/Sparkle.h>

static NSString * const AppSupportDirectory = @"Menu Utility";
static NSString * const LayoutPath          = @"Layout";
static NSString * const SettingsPath        = @"Settings";
static NSString * const LauncherPath        = @"Launcher.app";
static CFTimeInterval const EventStreamLatency = 1.0f;

static void FSEventCallback(ConstFSEventStreamRef streamRef,
                            void *clientCallBackInfo,
                            size_t numEvents,
                            void *eventPaths,
                            const FSEventStreamEventFlags eventFlags[],
                            const FSEventStreamEventId eventIds[]) {
    FCMenuItemDelegate * me = (__bridge FCMenuItemDelegate *) clientCallBackInfo;
    [me updateStatusItem];
}

static NSString * appSupportPath() {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSURL * appSupportUrl = [fileManager URLForDirectory:NSApplicationSupportDirectory
                                                inDomain:NSLocalDomainMask
                                       appropriateForURL:NULL
                                                  create:NO
                                                   error:NULL];
    return [[appSupportUrl path] stringByAppendingPathComponent:AppSupportDirectory];
}

@implementation FCMenuItemDelegate
- (id) initWithMenuItemView:(FCMenuItemView *)aView {
    if (self = [super init]) {
        view = aView;
        [self configureControlMenu];
        [self updateStatusItem];
    }
    return self;
}

- (void) start {
    NSString * appSupportDir = appSupportPath();
    NSArray * paths = [NSArray arrayWithObject:appSupportDir];

    FSEventStreamContext context = {0};
    context.info = (__bridge void *)(self);

    stream = FSEventStreamCreate(kCFAllocatorDefault,
                                 &FSEventCallback,
                                 &context,
                                 (__bridge CFArrayRef)(paths),
                                 kFSEventStreamEventIdSinceNow,
                                 EventStreamLatency,
                                 kFSEventStreamCreateFlagNone);
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    
    FSEventStreamStart(stream);
}

- (void) stop {
    FSEventStreamStop(stream);
    FSEventStreamInvalidate(stream);
    FSEventStreamRelease(stream);
    stream = NULL;
}

- (void) updateStatusItem {
    // Find settings path, either in Application Support or the defaults in
    // the app bundle.
    NSString * appSupportDir = appSupportPath();
    NSBundle * settingsBundle = [NSBundle bundleWithPath:appSupportDir];
    
    [[view layoutMenu] removeAllItems];
    [self addAppVersionToMenu];
    [self updateLauncherWithSettingsBundle:settingsBundle];
    
    if (settingsBundle) {
        [self updateMenu: [view layoutMenu]
          withLayoutPath: [[settingsBundle resourcePath] stringByAppendingPathComponent:LayoutPath]];
    }
}

- (void) addAppVersionToMenu {
    NSString * name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if (name && version)
    {
        [[view layoutMenu] addItemWithTitle:[NSString stringWithFormat:@"%@ - v%@", name, version]
                                     action:nil
                              keyEquivalent:@""];
        [[view layoutMenu] addItem:[NSMenuItem separatorItem]];
    }
}

- (void) updateLauncherWithSettingsBundle:(NSBundle *)aBundle {
    if (aBundle) {
        NSString * launcherPath = [[aBundle resourcePath] stringByAppendingPathComponent:LauncherPath];
        NSString * launcherType = [[NSWorkspace sharedWorkspace] typeOfFile:launcherPath error:nil];
        if (launcherType) {
            if (UTTypeConformsTo((__bridge CFStringRef)(launcherType), kUTTypeApplication)) {
                [view setLauncherPath:launcherPath];
                return;
            }
        }
    }
    
    [view setLauncherPath:nil];
}

- (void) updateMenu:(NSMenu *)aMenu withLayoutPath:(NSString *)aPath {
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
        
        [self updateMenu:aMenu withLayoutPath:groupPath];
        [aMenu addItem:[NSMenuItem separatorItem]];
        groupIndex++;
    }
    
    if (groupIndex > 1) {
        [aMenu removeItemAtIndex:([aMenu numberOfItems] - 1)];
        return;
    }
    
    NSArray * files = [manager contentsOfDirectoryAtPath:aPath error:nil];
    files = [files sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString * file in files) {
        if ([file isEqualToString:SettingsPath]) {
            continue;
        }
        
        NSString* filePath = [aPath stringByAppendingPathComponent:file];
        
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
            [self updateMenu:submenu withLayoutPath:filePath];
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

- (void) configureControlMenu {
    NSMenu * controlMenu = [view controlMenu];
    NSMenuItem * item = [controlMenu addItemWithTitle:@"Open Layout Folder"
                                               action:@selector(openLayoutFolder:)
                                        keyEquivalent:@""];
    [item setTarget:self];
    
    item = [controlMenu addItemWithTitle:@"Check for Updates..."
                                  action:@selector(checkForUpdates:)
                           keyEquivalent:@""];
    [item setTarget:[SUUpdater sharedUpdater]];
    
    [controlMenu addItem:[NSMenuItem separatorItem]];
    
    item = [controlMenu addItemWithTitle:@"Quit Menu Utility"
                                  action:@selector(terminate:)
                           keyEquivalent:@""];
    [item setTarget:NSApp];
}

- (void)openLayoutFolder:(id)sender {
    NSString * appSupportDir = appSupportPath();
    NSBundle * settingsBundle = [NSBundle bundleWithPath:appSupportDir];
    
    if (settingsBundle) {
        [[NSWorkspace sharedWorkspace] openFile:[[settingsBundle resourcePath] stringByAppendingPathComponent:LayoutPath]];
    }
}

@end
