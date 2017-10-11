//
//  UIView+createSubviews.m
//  AicaiLottery
//
//  Created by zmz on 17/2/10.
//  Copyright © 2017年 lihuihan. All rights reserved.
//

#import "UIView+createSubviews.h"

@implementation UIView (createSubviews)

- (UIView *)createView:(CGRect)rect backColor:(UIColor *)backColor {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    backColor ? [view setBackgroundColor:backColor] : nil;
    [self addSubview:view];
    return view;
}

//- (UIImageView *)createImgv:(CGRect)rect URL:(NSString *)URL holder:(UIImage *)holder {
//    UIImageView *imgv = [[UIImageView alloc] initWithFrame:rect];
//    if (holder) {
//        imgv.image = holder;
//    }
//    if (URL && URL.length > 0) {
//        [imgv sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:holder];
//    }
//    [self addSubview:imgv];
//    return imgv;
//}

- (UILabel *)createLabel:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backColor:(UIColor *)backClor align:(NSTextAlignment)align text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = (font ? font : [UIFont systemFontOfSize:14]);
    label.textColor = (color ? color : RGBHEX_(#333333));
    label.text = (text ? text : @"");
    backClor ? label.backgroundColor = backClor : nil;
    label.textAlignment = align;
    [self addSubview:label];
    return label;
}

- (UIButton *)createButton:(CGRect)rect imageName:(NSString *)imageName font:(UIFont *)font color:(UIColor *)color backColor:(UIColor *)backClor text:(NSString *)text {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    button.titleLabel.font = font;
    button.backgroundColor = backClor;
    [button setImage:imageName ? [UIImage imageNamed:imageName] : nil forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    color ? [button setTitleColor:color forState:UIControlStateNormal] : nil;
    [self addSubview:button];
    return button;
}

- (UITextField *)createTextField:(CGRect)rect font:(UIFont *)font color:(UIColor *)color align:(NSTextAlignment)align {
    UITextField *text = [[UITextField alloc] initWithFrame:rect];
    text.font = font;
    text.textColor = color;
    text.textAlignment = align;
    [self addSubview:text];
    return text;
}

- (UITextField *)createTextField:(CGRect)rect font:(UIFont *)font color:(UIColor *)color align:(NSTextAlignment)align borderColor:(UIColor *)borderColor leftSpace:(CGFloat)leftSpace holder:(NSString *)holder {
    UITextField *field = [self createTextField:rect font:font color:color align:align];
    if (borderColor) {
        field.layer.borderWidth = 0.5;
        field.layer.borderColor = [borderColor CGColor];
    }
    field.placeholder = holder;
    if (leftSpace > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftSpace, CGRectGetHeight(rect))];
        view.backgroundColor = [UIColor clearColor];
        field.leftView = view;
        field.leftViewMode = UITextFieldViewModeAlways;
    }
    return field;
}

#pragma mark - 画圆角
- (void)doBorderWidthCornerRedius:(CGFloat)cornerRedius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
    self.layer.cornerRadius = cornerRedius;
    self.layer.masksToBounds = YES;
}

@end
