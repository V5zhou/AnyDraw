//
//  AnyPublicMethod.m
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyPublicMethod.h"

@implementation AnyPublicMethod

/**
 画笔选择器图片
 */
+ (NSString *)brushCubeImage:(AnyBrushType)type {
    switch (type) {
        case AnyBrushType_BallPen:  ///< 圆珠笔
            return @"stylishbrush_ballpoint_pen";
            break;
        case AnyBrushType_TiltPen:  ///< 倾斜笔
            return @"stylishbrush_felt_pen";
            break;
        case AnyBrushType_MiPen:    ///< 米形笔
            return @"stylishbrush_flowers";
            break;
        case AnyBrushType_Spray:    ///< 喷枪
            return @"stylishbrush_air_brush";
            break;
        case AnyBrushType_Eraser:   ///< 橡皮擦
            return @"stylishbrush_head_eraser";
            break;
        case AnyBrushType_Fish:     ///< 鱼形笔
            return @"stylishbrush_fish";
            break;
        case AnyBrushType_Crayon:   ///< 蜡笔
            return @"stylishbrush_oil_pastel";
            break;
    }
}

/**
 已选择画笔图片(视图左下角)
 */
+ (NSString *)brushSelectedImage:(AnyBrushType)type {
    switch (type) {
        case AnyBrushType_BallPen:  ///< 圆珠笔
            return @"main_brush_icon_09";
            break;
        case AnyBrushType_TiltPen:  ///< 倾斜笔
            return @"main_brush_icon_12";
            break;
        case AnyBrushType_MiPen:    ///< 米形笔
            return @"main_brush_icon_16";
            break;
        case AnyBrushType_Spray:    ///< 喷枪
            return @"main_brush_icon_10";
            break;
        case AnyBrushType_Eraser:   ///< 橡皮擦
            return @"main_brush_icon_07";
            break;
        case AnyBrushType_Fish:     ///< 鱼形笔
            return @"main_brush_icon_26";
            break;
        case AnyBrushType_Crayon:   ///< 蜡笔
            return @"main_brush_icon_14";
            break;
    }
}

/**
 画笔绘制使用图片（绘制路径上使用小图片）
 */
+ (NSString *)brushDrawImage:(AnyBrushType)type {
    switch (type) {
        case AnyBrushType_BallPen:  ///< 圆珠笔
            return @"----";
            break;
        case AnyBrushType_TiltPen:  ///< 倾斜笔
            return @"brush_33";
            break;
        case AnyBrushType_MiPen:    ///< 米形笔
            return @"brush_47";
            break;
        case AnyBrushType_Spray:    ///< 喷枪
            return @"brush_05";
            break;
        case AnyBrushType_Eraser:   ///< 橡皮擦
            return @"----";
            break;
        case AnyBrushType_Fish:     ///< 鱼形笔
            return @"brush_49";
            break;
        case AnyBrushType_Crayon:   ///< 蜡笔
            return @"brush_05";
            break;
    }
}

@end
