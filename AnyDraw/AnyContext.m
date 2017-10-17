//
//  AnyContext.m
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyContext.h"

@implementation AnyContext

/**
 创建环境
 */
+ (instancetype)createWithBrushType:(AnyBrushType)brushType {
    AnyContext *context = [[AnyContext alloc] init];
    context.brushType = brushType;
    [context loadDefaultSetting];
    return context;
}

//每个画笔类型都有个默认值
- (void)loadDefaultSetting {
    switch (_brushType) {
        case AnyBrushType_BallPen:
        {
            _maxWidth = 10;
            _minWidth = 1;
            _lineWidth = 3;
            _strokeColor = [UIColor colorWithHex:0x142522 andAlpha:0.8];
        }
            break;
        case AnyBrushType_TiltPen:
        {
            _maxWidth = 50;
            _minWidth = 10;
            _lineWidth = 15;
            _strokeColor = [UIColor colorWithHex:0x42125c andAlpha:0.8];
        }
            break;
        case AnyBrushType_MiPen:
        {
            _maxWidth = 40;
            _minWidth = 15;
            _lineWidth = 20;
            _strokeColor = [UIColor colorWithHex:0xe93e47 andAlpha:0.8];
        }
            break;
        case AnyBrushType_Spray:
        {
            _maxWidth = 30;
            _minWidth = 10;
            _lineWidth = 18;
            _strokeColor = [UIColor colorWithHex:0x20b0dc andAlpha:0.8];
        }
            break;
        case AnyBrushType_Fish:
        {
            _maxWidth = 50;
            _minWidth = 10;
            _lineWidth = 24;
            _strokeColor = [UIColor colorWithHex:0xb020dc andAlpha:0.8];
        }
            break;
        case AnyBrushType_Eraser:
        {
            _maxWidth = 30;
            _minWidth = 3;
            _lineWidth = 6;
            _strokeColor = [UIColor clearColor];
        }
            break;
        case AnyBrushType_Crayon:
        {
            _maxWidth = 40;
            _minWidth = 15;
            _lineWidth = 20;
            _strokeColor = [UIColor colorWithHex:0xff1111 andAlpha:0.8];
        }
            break;
        case AnyBrushType_Oil:      ///< 油彩笔
            _maxWidth = 30;
            _minWidth = 10;
            _lineWidth = 14;
            _strokeColor = [UIColor colorWithHex:0xff1111 andAlpha:0.8];
            break;
    }
}

@end
