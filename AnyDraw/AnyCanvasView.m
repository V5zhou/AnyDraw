//
//  AnyCanvasView.m
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyCanvasView.h"
#import "AnyBitMap.h"

@interface AnyCanvasView ()

@property (nonatomic, assign) AnyBrushType curruntBrushType;///< 当前画笔类型
@property (nonatomic, strong) AnyPath *curruntPath;         ///< 当前绘制路径
@property (nonatomic, strong) NSMutableDictionary *contexts;///< 绘制环境列表：缓存为字典，每种画笔环境独立控制

@property (nonatomic, strong) CAShapeLayer *shapLayer;      ///< 中间层layer：绘制中的path或bitmap图片，实时绘制到此layer上

//绘制方式有两种，一种path，一种bitmap
@property (nonatomic, strong) AnyBitMap *bitmap;

@end

@implementation AnyCanvasView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadDefaultSetting];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shapLayer.frame = self.bounds;
}

- (void)loadDefaultSetting {
    //子layer设置
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineJoin = kCALineJoinRound;
    layer.lineCap = kCALineCapRound;
    [self.layer addSublayer:layer];
    self.shapLayer = layer;
    
    //初始化设置为圆珠笔
    _curruntBrushType = AnyBrushType_BallPen;
    _curruntContext = [AnyContext createWithBrushType:AnyBrushType_BallPen];
    _contexts = [NSMutableDictionary dictionaryWithObject:_curruntContext forKey:@(AnyBrushType_BallPen)];
}

#pragma mark - setter & getter
- (void)changeBrushType:(AnyBrushType)brushType finished:(void(^)(AnyContext *curruntContext))finished {
    //画笔类型改变，变换对应context
    if (_curruntBrushType != brushType) {
        AnyContext *context = [_contexts objectForKey:@(brushType)];
        if ([context isKindOfClass:[AnyContext class]]) {
            self.curruntContext = context;
        }
        else {  //如果不存在此类型，创建并缓存到字典
            self.curruntContext = [AnyContext createWithBrushType:brushType];
            [self.contexts setObject:_curruntContext forKey:@(brushType)];
        }
    }
    
    //
    _curruntBrushType = brushType;
    
    if (finished) {
        finished(_curruntContext);
    }
}

#pragma mark - 绘制
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    kWeakSelf
    self.curruntPath = [AnyPath createWithContext:_curruntContext callBack:^(BOOL isBitmap, UIBezierPath *bezier, AnyTouchesType touchType) {
        //一种通过path直接画，另一种在bitMap上画
        if (isBitmap) {
            switch (touchType) {
                case AnyTouchesType_began:
                {
                    weakSelf.bitmap = [AnyBitMap createWithSize:weakSelf.frame.size context:weakSelf.curruntContext];
                }
                    break;
                case AnyTouchesType_move:
                {
                    weakSelf.shapLayer.contents = (__bridge id _Nullable)([weakSelf.bitmap addBezier:bezier].CGImage);
                }
                    break;
                case AnyTouchesType_end:
                {
                    weakSelf.shapLayer.contents = (__bridge id _Nullable)([weakSelf.bitmap addBezier:bezier].CGImage);
                }
                    break;
                    
                default:
                    break;
            }
        }
        else {
            //橡皮擦功能
            if (weakSelf.curruntBrushType == AnyBrushType_Eraser) {
                [weakSelf eraseWithBezier:bezier];
            }
            else {
                CAShapeLayer *layer = weakSelf.shapLayer;
                layer.strokeColor = weakSelf.curruntContext.strokeColor.CGColor;
                layer.lineWidth = weakSelf.curruntContext.lineWidth;
                layer.path = bezier.CGPath;
            }
        }
        
        //通知AnyDrawMainView保存新步骤
        if (weakSelf.stepCallBack) {
            weakSelf.stepCallBack(touchType, weakSelf.curruntPath);
        }
        
        //清除子layer当前笔,准备接收下一笔
        if (touchType == AnyTouchesType_end) {
            if (isBitmap) {
                weakSelf.shapLayer.contents = nil;
                [weakSelf.bitmap endBitMap];
            }
            else {
                weakSelf.shapLayer.path = nil;
            }
        }
    }];
    [_curruntPath moveToPoint:TouchPoint(touches) touchType:AnyTouchesType_began];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_curruntPath moveToPoint:TouchPoint(touches) touchType:AnyTouchesType_move];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_curruntPath moveToPoint:TouchPoint(touches) touchType:AnyTouchesType_end];
}

static CGPoint TouchPoint(NSSet<UITouch *> *touches) {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    return point;
}

#pragma mark - 橡皮擦
- (void)eraseWithBezier:(UIBezierPath *)bezier {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    [[UIColor clearColor] set];
    bezier.lineWidth = _curruntContext.lineWidth;
    [bezier strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    [bezier stroke];
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.contents = (__bridge id _Nullable)(outImage.CGImage);
}

@end
