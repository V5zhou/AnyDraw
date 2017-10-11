//
//  AnyPath.h
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnyContext.h"

typedef void(^AnyPathCallBack)(BOOL isBitmap, UIBezierPath *bezier, AnyTouchesType touchType);

@interface AnyPath : NSObject

@property (nonatomic, strong) AnyContext *context;

@property (nonatomic, strong) NSMutableArray *points;           ///< 缓存点

@property (nonatomic, assign) NSTimeInterval startInteval;      ///< 开始touchesBegan时间点

/**
 创建新Path
 */
+ (instancetype)createWithContext:(AnyContext *)context callBack:(AnyPathCallBack)callBack;

/**
 接收点
 */
- (void)moveToPoint:(CGPoint)point touchType:(AnyTouchesType)touchType;

@end
