#import <Foundation/Foundation.h>

@interface FCMenuItemController : NSObject {
    NSString * appLayoutPath;
    NSString * localLayoutPath;
    NSString * userLayoutPath;
}

@property (readonly) NSMenu * layoutMenu;
@property (readonly) NSMenu * controlMenu;

- (void) repopulateMainMenu;
- (NSArray *) layoutPaths;
- (void) handleItemsDroppedFromPasteboard:(NSPasteboard *) aPasteboard;

@end
