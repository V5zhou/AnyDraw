//
//  AnyQueue.m
//  AnyDraw
//
//  Created by zmz on 2017/11/6.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyQueue.h"

@implementation AnyQueue

+ (NSOperationQueue *)mainQueue {
    return [NSOperationQueue mainQueue];
}

+ (NSOperationQueue *)serierQueue {
    static NSOperationQueue *serierQueue_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serierQueue_ = [[NSOperationQueue alloc] init];
        serierQueue_.maxConcurrentOperationCount = 1;
    });
    return serierQueue_;
}

+ (NSOperationQueue *)concurrenceQueue {
    static NSOperationQueue *concurrenceQueue_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        concurrenceQueue_ = [[NSOperationQueue alloc] init];
        concurrenceQueue_.maxConcurrentOperationCount = 8;
    });
    return concurrenceQueue_;
}

@end
