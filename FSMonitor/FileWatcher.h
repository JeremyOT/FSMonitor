//
//  FileWatcher.h
//  FSMonitor
//
//  Created by Jeremy Olmsted-Thompson on 8/23/11.
//  Copyright 2011 JOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileWatcher : NSObject {
    void (^callbackBlock)(NSString*, FSEventStreamEventFlags);
    FSEventStreamRef eventStream;
}

-(id)initWithBlock:(void (^)(NSString*, FSEventStreamEventFlags))block;
-(void)openEventStream:(NSArray*)pathsToWatch latency:(NSTimeInterval)latency;
-(void)close;

@end
