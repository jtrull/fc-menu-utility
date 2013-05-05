#import <Foundation/Foundation.h>

@interface FCMenuItemDelegate : NSObject
{
}

- (void) populateMainMenu:(NSMenu *) aMenu;
- (void) populateControlMenu:(NSMenu *) aMenu;
- (void) handleItemsDroppedFromPasteboard:(NSPasteboard *) aPasteboard;

@end
