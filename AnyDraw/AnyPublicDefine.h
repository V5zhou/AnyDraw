//
//  AnyPublicDefine.h
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#ifndef AnyPublicDefine_h
#define AnyPublicDefine_h

#define kSCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define kSCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define kWeakSelf __weak typeof(self) weakSelf = self;

#define kTagStart 1000

#pragma mark - 触摸类型
typedef NS_ENUM(NSUInteger, AnyTouchesType) {
    AnyTouchesType_began = 0,   ///< 开始
    AnyTouchesType_move,        ///< 移动
    AnyTouchesType_end,         ///< 结束
};

#pragma mark - 笔类型
typedef NS_ENUM(NSUInteger, AnyBrushType) {
    AnyBrushType_BallPen = 0,   ///< 圆珠笔
    AnyBrushType_TiltPen,       ///< 倾斜笔
    AnyBrushType_MiPen,         ///< 米形笔
    AnyBrushType_Spray,         ///< 喷枪
    AnyBrushType_Eraser,        ///< 橡皮擦
    AnyBrushType_Fish,          ///< 鱼形笔
    AnyBrushType_Crayon,        ///< 蜡笔
};

#pragma mark - 颜色选择器
typedef NS_ENUM(NSUInteger, ColorPickerType) {
    ColorPickerType_Default = 0,    ///< 预设
    ColorPickerType_Circle,         ///< 圆环
};

#endif /* AnyPublicDefine_h */
