//
//  AnyContext.h
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnyContext : NSObject


/**
 创建环境
 */
+ (instancetype)createWithBrushType:(AnyBrushType)brushType;

@property (nonatomic, assign) AnyBrushType brushType;       ///< 画笔类型
@property (nonatomic, strong) UIColor *strokeColor;         ///< 画笔颜色
@property (nonatomic, assign) CGFloat lineWidth;            ///< 线粗细
@property (nonatomic, assign) CGFloat maxWidth;             ///< 最粗
@property (nonatomic, assign) CGFloat minWidth;             ///< 最细

@end
