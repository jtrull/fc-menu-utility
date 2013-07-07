#import <Cocoa/Cocoa.h>
#import "FCFSWatcher.h"

@interface FCAppDelegate : NSObject <NSApplicationDelegate> {
    FCFSWatcher * watcher;
}
@end
