//
//  NSString+size.m
//  SimplePalette
//
//  Created by zmz on 2017/9/19.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "NSString+size.h"

@implementation NSString (size)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName : font}];
    CGRect rect = [attribute boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
    return rect.size;
}

#endif

@end
