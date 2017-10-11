//
//  UIButton+block.h
//  UIAnimationTest
//
//  Created by zmz on 2017/8/23.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (block)

/**
 ##添加一个UIControlEventTouchUpInside事件

 @param action *响应block*
 */
- (void)setsAction:(void(^)(UIButton *button))action;

@end
