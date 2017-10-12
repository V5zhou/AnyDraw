//
//  AnyCanvasView.h
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnyCanvasView : UIView

- (void)changeBrushType:(AnyBrushType)brushType finished:(void(^)(AnyContext *curruntContext))finished;

@property (nonatomic, strong) AnyContext *curruntContext;   ///< 当前绘制环境

@property (nonatomic, strong) void(^stepCallBack)(AnyPath *curruntPath, UIImage *canvasImage);

@end
