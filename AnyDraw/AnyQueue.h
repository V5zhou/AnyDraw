//
//  AnyQueue.h
//  AnyDraw
//
//  Created by zmz on 2017/11/6.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnyQueue : NSObject

+ (NSOperationQueue *)mainQueue;
+ (NSOperationQueue *)serierQueue;
+ (NSOperationQueue *)concurrenceQueue;

@end
