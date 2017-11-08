//
//  UIView+category.m
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "UIView+category.h"

@implementation UIView (category)

#pragma mark - 截屏
- (UIImage *)screenShot {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
