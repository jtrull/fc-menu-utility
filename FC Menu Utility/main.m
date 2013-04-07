#import <Cocoa/Cocoa.h>

#import "FCAppDelegate.h"

int main(int argc, char *argv[])
{
    NSApplication * app = [NSApplication sharedApplication];
    FCAppDelegate * delegate = [[FCAppDelegate alloc] init];
    
    [app setDelegate:delegate];
    [app run];
    
    return EXIT_SUCCESS;
}
