#import <Foundation/Foundation.h>
#import "FCMenuItemView.h"

@interface FCMenuItemController : NSObject
{
    FCMenuItemView * view;
    FSEventStreamRef stream;
}

- (id) initWithMenuItemView:(FCMenuItemView *) aView;
- (void) start;
- (void) stop;
- (void) updateStatusItem;
@end
