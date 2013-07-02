#import <Foundation/Foundation.h>

@interface FCMenuItemController : NSObject
{
}

- (void) populateMainMenu:(NSMenu *) aMenu;
- (void) populateControlMenu:(NSMenu *) aMenu;
- (void) handleItemsDroppedFromPasteboard:(NSPasteboard *) aPasteboard;

@end
