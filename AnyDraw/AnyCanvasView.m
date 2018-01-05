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
@property (nonatomic, strong) NSMutableSet *bitmapSet;       ///< 添加一个set，防止绘制任务还未完成时，就已经释放bitmap导致的crash

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
    layer.frame = self.bounds;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineJoin = kCALineJoinRound;
    layer.lineCap = kCALineCapRound;
    [self.layer addSublayer:layer];
    self.shapLayer = layer;
    
    _bitmapSet = [NSMutableSet set];
    
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
        //当前layer更新后回调
        void (^layerRefreshFinishedCallBack)(AnyBitMap *bitMap) = ^(AnyBitMap *bitMap) {
            
            if (touchType == AnyTouchesType_end) {
                //开始生成图片
                UIImage *canvasImage = [weakSelf screenShot];
                weakSelf.layer.contents = (__bridge id _Nullable)(canvasImage.CGImage);
                
                //通知AnyDrawMainView保存新步骤
                if (weakSelf.stepCallBack) {
                    weakSelf.stepCallBack(weakSelf.curruntPath, canvasImage);
                }
                
                //清除子layer当前笔,准备接收下一笔
                if (isBitmap) {
                    weakSelf.shapLayer.contents = nil;
                    if (bitMap) {
                        [weakSelf.bitmap endBitMap];               //直接通知结束绘制，即使线程中仍然有正在绘制的path
                        [weakSelf.bitmapSet removeObject:bitMap];  //移除出数组
                        weakSelf.bitmap = nil;
                    }
                }
                else {
                    weakSelf.shapLayer.path = nil;
                }
            }
        };
        
        //一种通过path直接画，另一种在bitMap上画，完成layer更新后执行回调
        if (isBitmap) {
            switch (touchType) {
                case AnyTouchesType_began:
                {
                    AnyBitMap *bitmap = [AnyBitMap createWithSize:weakSelf.frame.size context:weakSelf.curruntContext];
                    [weakSelf.bitmapSet addObject:bitmap];  //添加进数组
                    weakSelf.bitmap = bitmap;
                }
                    break;
                case AnyTouchesType_move:
                case AnyTouchesType_end:
                {
                    [weakSelf.bitmap addBezier:bezier resultImage:^(AnyBitMap *bitMap, UIImage *image) {
                        weakSelf.shapLayer.contents = (__bridge id _Nullable)(image.CGImage);
                        layerRefreshFinishedCallBack(bitMap);
                    }];
                    
                }
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
            layerRefreshFinishedCallBack(nil);
        }
    }];
    [_curruntPath asyncMoveToPoint:TouchPoint(touches) touchType:AnyTouchesType_began];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_curruntPath asyncMoveToPoint:TouchPoint(touches) touchType:AnyTouchesType_move];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_curruntPath asyncMoveToPoint:TouchPoint(touches) touchType:AnyTouchesType_end];
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
