//
//  UIView+expand.m
//  UIAnimationTest
//
//  Created by zmz on 2017/8/28.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "UIView+expand.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIView (expand)

static char hitTestView_bind;
- (void)setHitTestView:(UIView *)hitTestView {
    NSString *className = [self newClassName];
    
    if (!NSClassFromString(className)) {
        //创建新类
        Class originalClazz = object_getClass(self);
        Class newClass = objc_allocateClassPair(originalClazz, className.UTF8String, 0);
        objc_registerClassPair(newClass);
        
        //添加hittest方法实现
        const char *types = "@:@";
        class_addMethod(NSClassFromString(className), @selector(hitTest:withEvent:), (IMP)hitTestWithEvent, types);
    }
    
    //把自己指向新类
    object_setClass(self, NSClassFromString(className));
    
    objc_setAssociatedObject(self, &hitTestView_bind, hitTestView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)hitTestView {
    return objc_getAssociatedObject(self, &hitTestView_bind);
}

//新增类名
- (NSString *)newClassName {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByAppendingString:@"_expandResponseRect"];
    return className;
}

UIView *hitTestWithEvent(UIView *self, SEL _cmd, CGPoint point, UIEvent *event) {
    //objc调用父类
    struct objc_super superclazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    id (*objc_msgSendSuperCasted)(void *, SEL, CGPoint, id) = (void *)objc_msgSendSuper;
    
    //如果不在父类范围，检查是否在expandResponseView上
    UIView *view = objc_msgSendSuperCasted(&superclazz, _cmd, point, event);
    if (!view) {
        UIView *expandResponseView = self.hitTestView;
        if (expandResponseView &&
            CGRectContainsPoint(expandResponseView.frame, point)) {
            return expandResponseView;
        }
    }
    return view;
}

@end
