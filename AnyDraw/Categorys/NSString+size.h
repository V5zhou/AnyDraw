//
//  NSString+size.h
//  SimplePalette
//
//  Created by zmz on 2017/9/19.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (size)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

#endif

@end
