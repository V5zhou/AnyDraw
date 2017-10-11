//
//  AnyColorBox.h
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnyColorBox : UIView

/**
 创建
 */
+ (instancetype)showWithType:(ColorPickerType)type color:(UIColor *)color selectAction:(void(^)(UIColor *color))selectAction;

@end
