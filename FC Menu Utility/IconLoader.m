#import "IconLoader.h"

NSString * const IconFile      = @"icon";
NSString * const AltIconFile   = @"alt-icon";
NSString * const IconExtension = @"png";

NSImage * loadImageFromBundle(NSBundle * aBundle, NSString * imageName) {
    if ([aBundle respondsToSelector:@selector(imageForResource:)]) {
        return [aBundle imageForResource:imageName];
    } else {
        NSString * imageFileName = [imageName stringByAppendingPathExtension:IconExtension];
        return [[NSImage alloc] initWithContentsOfFile:
                [[aBundle resourcePath] stringByAppendingPathComponent:imageFileName]];
    }
}
