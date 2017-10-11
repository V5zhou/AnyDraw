//
//  AnyPublicMethod.h
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnyPublicMethod : NSObject

/**
 画笔选择器图片
 */
+ (NSString *)brushCubeImage:(AnyBrushType)type;

/**
 已选择画笔图片(视图左下角)
 */
+ (NSString *)brushSelectedImage:(AnyBrushType)type;

/**
 画笔绘制使用图片（绘制路径上使用小图片）
 */
+ (NSString *)brushDrawImage:(AnyBrushType)type;

@end
