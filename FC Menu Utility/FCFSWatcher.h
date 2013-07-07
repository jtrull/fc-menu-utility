#import <Foundation/Foundation.h>

@interface FCFSWatcher : NSObject {
    NSArray * watchPaths;
    SEL notifySelector;
    id notifyObject;
    FSEventStreamRef stream;
}

- (id)         initWithWatchPaths:(NSArray *) paths
       performingSelectorOnChange:(SEL) aSelector
                       withObject:(id) anObject;
- (void) start;
- (void) stop;
- (void) sendNotifications;

@end
