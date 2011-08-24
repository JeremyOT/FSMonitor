//
//  FileWatcher.m
//  FSMonitor
//
//  Created by Jeremy Olmsted-Thompson on 8/23/11.
//  Copyright 2011 JOT. All rights reserved.
//

#import "FileWatcher.h"

@implementation FileWatcher

static void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[]) {
    for(int i = 0; i < numEvents; i++) {
        ((FileWatcher*)userData)->callbackBlock([(NSArray *)eventPaths objectAtIndex:i], eventFlags[i]);
    }
}

#pragma mark -
#pragma mark Initialization

-(id)initWithBlock:(void (^)(NSString*, FSEventStreamEventFlags))block {
    if ((self = [super init])) {
        callbackBlock = [block copy];
    }
    return self;
}

-(id)init {
    return [self initWithBlock:^(NSString* changed, FSEventStreamEventFlags flags) {
        NSLog(@"%@", changed);
    }];
}

#pragma mark -
#pragma mark Stream

-(void)openEventStream:(NSArray*)pathsToWatch latency:(NSTimeInterval)latency {
    [self close];
    if (![pathsToWatch count]) {
        pathsToWatch = [NSArray arrayWithObject:@"/"];
    }
    FSEventStreamContext context = {0, (void *)self, NULL, NULL, NULL};
    eventStream = FSEventStreamCreate(NULL,
                                      &fsevents_callback,
                                      &context,
                                      (CFArrayRef) pathsToWatch,
                                      kFSEventStreamEventIdSinceNow,
                                      (CFAbsoluteTime) latency,
                                      kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents
                                      );
    
    FSEventStreamScheduleWithRunLoop(eventStream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(eventStream);
}

-(void)close {
    if (eventStream) {
        FSEventStreamStop(eventStream);
        FSEventStreamInvalidate(eventStream);
        eventStream = NULL;
    }
}

#pragma mark -

-(void)dealloc {
    [self close];
    [callbackBlock release];
    [super dealloc];
}

@end