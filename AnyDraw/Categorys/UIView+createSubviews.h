//
//  UIView+createSubviews.h
//  AicaiLottery
//
//  Created by zmz on 17/2/10.
//  Copyright © 2017年 lihuihan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (createSubviews)

- (UIView *)createView:(CGRect)rect backColor:(UIColor *)backColor;

//- (UIImageView *)createImgv:(CGRect)rect URL:(NSString *)URL holder:(UIImage *)holder;

- (UILabel *)createLabel:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backColor:(UIColor *)backClor align:(NSTextAlignment)align text:(NSString *)text;

- (UIButton *)createButton:(CGRect)rect imageName:(NSString *)imageName font:(UIFont *)font color:(UIColor *)color backColor:(UIColor *)backClor text:(NSString *)text;

- (UITextField *)createTextField:(CGRect)rect font:(UIFont *)font color:(UIColor *)color align:(NSTextAlignment)align;
- (UITextField *)createTextField:(CGRect)rect font:(UIFont *)font color:(UIColor *)color align:(NSTextAlignment)align borderColor:(UIColor *)borderColor leftSpace:(CGFloat)leftSpace holder:(NSString *)holder;

#pragma mark - 画圆角
- (void)doBorderWidthCornerRedius:(CGFloat)cornerRedius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

@end
