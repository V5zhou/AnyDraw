//
//  AnyDrawQueue.m
//  AnyDraw
//
//  Created by zmz on 2017/10/27.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyDrawQueue.h"

@implementation AnyDrawQueue

+ (instancetype)concurrenceQueue {
    static AnyDrawQueue *concurrence = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        concurrence = [[AnyDrawQueue alloc] init];
        concurrence.maxConcurrentOperationCount = 10;
    });
    return concurrence;
}

+ (instancetype)serialQueue {
    static AnyDrawQueue *serial = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serial = [[AnyDrawQueue alloc] init];
        serial.maxConcurrentOperationCount = 1;
    });
    return serial;
}

@end
