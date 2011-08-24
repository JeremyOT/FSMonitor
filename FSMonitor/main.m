//
//  main.m
//  FSMonitor
//
//  Created by Jeremy Olmsted-Thompson on 8/23/11.
//  Copyright 2011 JOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileWatcher.h"

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:argc - 1];
    for (int i = 1; i < argc; i++) {
        [paths addObject:[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
    }
    FileWatcher *watcher = [[FileWatcher alloc] initWithBlock:^(NSString *changedFile, FSEventStreamEventFlags flags) {
        printf("%s\n", [changedFile cStringUsingEncoding:NSUTF8StringEncoding]);
        fflush(stdout);
    }];
    [watcher openEventStream:paths latency:1.0];
    CFRunLoopRun();
    [pool drain];
    return 0;
}