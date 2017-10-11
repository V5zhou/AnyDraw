//
//  AnyPath.m
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyPath.h"

@interface AnyPath ()

@property (nonatomic, strong) UIBezierPath *bezier;

@property (nonatomic, copy)   AnyPathCallBack callBack;

@end

@implementation AnyPath

/**
 创建新Path
 */
+ (instancetype)createWithContext:(AnyContext *)context callBack:(AnyPathCallBack)callBack {
    AnyPath *path= [[AnyPath alloc] init];
    path.context = context;
    path.points = [NSMutableArray array];
    path.callBack = callBack;
    path.startInteval = [[NSDate date] timeIntervalSince1970];
    return path;
}

/**
 接收点
 */
- (void)moveToPoint:(CGPoint)point touchType:(AnyTouchesType)touchType {
    UIBezierPath *addPath;
    //如果不是同一点
    if (![NSStringFromCGPoint(point) isEqualToString:[self.points lastObject]] ||
        touchType == AnyTouchesType_end) {
        switch (touchType) {
            case AnyTouchesType_began:
                self.bezier = [UIBezierPath bezierPath];
                break;
            case AnyTouchesType_move:
            case AnyTouchesType_end:
                addPath = [self smoothLineWithNewPoint:point touchType:touchType];
                break;
        }
        
        //保存点
        [self.points addObject:NSStringFromCGPoint(point)];
        
//        //测试加个小圆环玩，会发现中点平滑方案情况下，bezier略微偏移
//        if (![self isNeedBitMap]) {
//            UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:point radius:_context.lineWidth startAngle:0 endAngle:M_PI * 2 clockwise:YES];
//            [self.bezier appendPath:circle];
//        }
    }
    
    //回调
    if (_callBack) {
        if ([self isNeedBitMap]) {  //bitMap方式，回调新增bezier;path方式，回调整个bezier。
            _callBack(YES, addPath, touchType);
        }
        else {
            _callBack(NO, self.bezier, touchType);
        }
    }
}

//矩齿修正
- (UIBezierPath *)smoothLineWithNewPoint:(CGPoint)point touchType:(AnyTouchesType)touchType {
    NSInteger pointNum = [_points count];
    
    UIBezierPath *newAddBezier = [UIBezierPath bezierPath];
    
    if (pointNum >= 2) {
        if (pointNum == 2) {   //补第一笔前半段
            CGPoint startPoint = CGPointFromString(_points[0]);
            CGPoint secondPoint = CGPointFromString(_points[1]);
            CGPoint centerPoint = CGPointMake((startPoint.x + secondPoint.x)/2, (startPoint.y + secondPoint.y)/2);
            [newAddBezier moveToPoint:startPoint];
            [newAddBezier addLineToPoint:centerPoint];
        }
        
        CGPoint previous1 = CGPointFromString(_points[pointNum - 1]);
        CGPoint previous2 = CGPointFromString(_points[pointNum - 2]);
        CGPoint mid1 = CGPointMake((previous1.x + point.x)/2, (previous1.y + point.y)/2);
        CGPoint mid2 = CGPointMake((previous1.x + previous2.x)/2, (previous1.y + previous2.y)/2);
        [newAddBezier moveToPoint:mid2];
        [newAddBezier addQuadCurveToPoint:mid1 controlPoint:previous1];
    }
    
    //画线结束
    if (touchType == AnyTouchesType_end) {
        if (pointNum == 1) {       //才保存了一个点，直接直线
            CGPoint previous1 = CGPointFromString(_points[pointNum - 1]);
            [newAddBezier moveToPoint:previous1];
            [newAddBezier addLineToPoint:point];
        }
        else {                      //补最后一笔后半段
            CGPoint previous1 = CGPointFromString(_points[pointNum - 1]);
            CGPoint mid1 = CGPointMake((previous1.x + point.x)/2, (previous1.y + point.y)/2);
            [newAddBezier moveToPoint:mid1];
            [newAddBezier addLineToPoint:point];
        }
    }
    
    [self.bezier appendPath:newAddBezier];
    return newAddBezier;
}

- (BOOL)isNeedBitMap {
    if (_context.brushType == AnyBrushType_BallPen ||
        _context.brushType == AnyBrushType_Eraser) {
        return NO;
    }
    return YES;
}

@end
