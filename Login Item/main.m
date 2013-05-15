//
//  main.m
//  Login Item
//
//  Created by Jonathan Trull on 5/14/13.
//  Copyright (c) 2013 Jonathan Trull. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <string.h>

#import "LoginItem.h"

static int usage() {
    fprintf(stderr, "Usage: manage-login-item install\n");
    fprintf(stderr, "       manage-login-item remove\n");
    return -1;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc != 2) {
            return usage();
        }
        
        if (!strncmp(argv[1], "install", 7)) {
            return installLoginItemIfNeeded();
        } else if (!strncmp(argv[1], "remove", 6)) {
            return removeLoginItemIfPresent();
        } else {
            return usage();
        }
    }
    return 0;
}

