//
//  UIButton+block.m
//  UIAnimationTest
//
//  Created by zmz on 2017/8/23.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "UIButton+block.h"
#import <objc/runtime.h>

@interface UIButton ()

@property (nonatomic, copy) void(^mzAction)(UIButton *button);

@end

@implementation UIButton (block)

- (void)setsAction:(void (^)(UIButton *))action {
    self.mzAction = action;
    [self addTarget:self action:@selector(actionTrigger:) forControlEvents:UIControlEventTouchUpInside];
}

static char mzAction_bind;
- (void)setMzAction:(void (^)(UIButton *))mzAction {
    objc_setAssociatedObject(self, &mzAction_bind, mzAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIButton *))mzAction {
    return objc_getAssociatedObject(self, &mzAction_bind);
}

- (void)actionTrigger:(UIButton *)button {
    if (self.mzAction) {
        self.mzAction(button);
    }
}

@end
