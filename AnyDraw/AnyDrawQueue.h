//
//  AnyDrawQueue.h
//  AnyDraw
//
//  Created by zmz on 2017/10/27.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AnyDrawConcurrenceQueue [AnyDrawQueue concurrenceQueue]
#define AnyDrawSerialQueue [AnyDrawQueue serialQueue]

@interface AnyDrawQueue : NSOperationQueue

+ (instancetype)concurrenceQueue;

+ (instancetype)serialQueue;

@end
