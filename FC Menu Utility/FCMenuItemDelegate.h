#import <Foundation/Foundation.h>
#import "FCMenuItemView.h"

@interface FCMenuItemDelegate : NSObject
{
    FCMenuItemView * view;
    FSEventStreamRef stream;
}

- (id) initWithMenuItemView:(FCMenuItemView *) aView;
- (void) start;
- (void) stop;
- (void) updateStatusItem;
@end
