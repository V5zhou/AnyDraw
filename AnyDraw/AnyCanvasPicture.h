//
//  AnyCanvasPicture.h
//  AnyDraw
//
//  Created by zmz on 2017/10/11.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnyCanvasPicture : UIView

/**
 创建
 */
+ (instancetype)showWithCurruntImageName:(NSString *)imageName selectAction:(void(^)(NSString *imageName))selectAction;

@end
