//
//  AnyBrushBox.h
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnyBrushBox : UIView

/**
 显示
 */
+ (instancetype)showWithSelectAction:(void(^)(AnyBrushType brushType))selectAction;

@end
