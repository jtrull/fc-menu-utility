#import "FCFSWatcher.h"

static CFTimeInterval const EventStreamLatency = 1.0f;

static void FSEventCallback(ConstFSEventStreamRef streamRef,
                            void *clientCallBackInfo,
                            size_t numEvents,
                            void *eventPaths,
                            const FSEventStreamEventFlags eventFlags[],
                            const FSEventStreamEventId eventIds[]) {
    FCFSWatcher * me = (__bridge FCFSWatcher *) clientCallBackInfo;
    [me sendNotifications];
}

@implementation FCFSWatcher
- (id)      initWithWatchPaths:(NSArray *) anArray
    performingSelectorOnChange:(SEL) aSelector
                    withObject:(id) anObject {
    self = [super init];
    
    if (self) {
        watchPaths = anArray;
        notifySelector = aSelector;
        notifyObject = anObject;
    }
    
    return self;
}

- (void) start {
    FSEventStreamContext context = {0};
    context.info = (__bridge void *)(self);
    
    stream = FSEventStreamCreate(kCFAllocatorDefault,
                                 &FSEventCallback,
                                 &context,
                                 (__bridge CFArrayRef)(watchPaths),
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

- (void) sendNotifications {
    [notifyObject performSelector:notifySelector];
}
@end
