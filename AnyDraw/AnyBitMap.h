//
//  AnyBitMap.h
//  AnyDraw
//
//  Created by zmz on 2017/10/10.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnyBitMap : NSObject

+ (instancetype)createWithSize:(CGSize)size context:(AnyContext *)context;
- (void)endBitMap;

- (void)addBezier:(UIBezierPath *)bezier resultImage:(void(^)(AnyBitMap *bitMap, UIImage *image))resultImage;

@end
