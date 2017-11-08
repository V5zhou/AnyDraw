//
//  AnyBitMap.m
//  AnyDraw
//
//  Created by zmz on 2017/10/10.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyBitMap.h"

@interface AnyBitMap ()

@property (nonatomic, assign) CGContextRef map;
@property (nonatomic, strong) AnyContext *context;
@property (nonatomic, assign) BOOL hasFoundFirstPoint;  //已经找到第一个点
@property (nonatomic, assign) CGPoint lastPoint;        //上次点
@property (nonatomic, assign) CGFloat extraLength;      //多余长度
@property (nonatomic, assign) CGPoint movePoint;        //记录move动作
@property (nonatomic, strong) UIImage *drawImage;

@end

//创建bitMap
CGContextRef BitMapCreate(CGSize size, CGFloat scale) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitMap = CGBitmapContextCreate(NULL,
                                       size.width * scale,
                                       size.height * scale,
                                       8,
                                       4 * size.width * scale,
                                       colorSpace,
                                       kCGImageAlphaPremultipliedLast);
    CGContextScaleCTM(bitMap, scale, scale);
    CGContextTranslateCTM(bitMap, 0, size.height);
    CGContextScaleCTM(bitMap, 1.0, -1.0);
    CGColorSpaceRelease( colorSpace );
    return bitMap;
}

@implementation AnyBitMap

+ (instancetype)createWithSize:(CGSize)size context:(AnyContext *)context {
    NSInteger scale = [UIScreen mainScreen].scale;
    
    AnyBitMap *bitMap = [[AnyBitMap alloc] init];
    bitMap.context = context;
    bitMap.map = BitMapCreate(size, scale);
    
    if (context.brushType == AnyBrushType_Crayon) {
        //绘制蜡笔纹理图片
        UIImage *image = [UIImage imageNamed:@"texture01"];
        UIImage *texttureImage = [UIImage imageWithSize:CGSizeMake(size.width * scale, size.height * scale) drawBlock:^(CGContextRef context) {
            for (NSInteger i = 0; ; i++) {
                if (image.size.height * i > size.height * scale) {
                    break;
                }
                for (NSInteger j = 0; ; j++) {
                    if (image.size.width * j > size.width * scale) {
                        break;
                    }
                    CGContextDrawImage(context, CGRectMake(image.size.width * j, image.size.height * i, image.size.width, image.size.height), image.CGImage);
                }
            }
        }];
        //把纹理图片设置bitmap的mask
        CGContextClipToMask(bitMap.map, CGRectMake(0, 0, size.width * scale, size.height * scale), texttureImage.CGImage);
    }

    return bitMap;
}

- (void)endBitMap {
    if (self.map) {
        @try {
            CGContextRelease(self.map);
        } @catch (NSException *exception) { } @finally { }
    }
}

- (void)addBezier:(UIBezierPath *)bezier resultImage:(void(^)(UIImage *image))resultImage {
    kWeakSelf
    [[AnyQueue serierQueue] addOperationWithBlock:^{
        CGPathApply(bezier.CGPath, (__bridge void * _Nullable)(weakSelf), DrawLayerCGPathApply);
        //取出图片
        CGImageRef cgImage = CGBitmapContextCreateImage(weakSelf.map);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        if (resultImage) {
            [[AnyQueue mainQueue] addOperationWithBlock:^{
                resultImage(image);
            }];
        }
    }];
}

#pragma mark - 线宽与分段数

/**
 线宽
 线宽默认取context.lineWidth
 但毛笔要求有粗细变化，粗细变化
 */
static CGFloat LineWidth(AnyContext *context, CGFloat pathLength) {
    CGFloat lineWidth = context.lineWidth;
    switch (context.brushType) {
        case AnyBrushType_MiPen:
        case AnyBrushType_Spray:
        {
            CGFloat maxWidth = lineWidth;
            CGFloat minWidth = lineWidth/3; //笔画画最快时，最小宽度限制。免得细的看不到了
            lineWidth = minWidth + (maxWidth - minWidth) * (10/MAX(10, pathLength));
        }
            break;
            
        default:
            break;
    }
    return lineWidth;
}

/**
 一个线宽长度上分段段数，段数越多绘制点越密集
 */
static CGFloat PointsEachWidth(AnyContext *context) {
    CGFloat widthPoints = 1;
    switch (context.brushType) {
        case AnyBrushType_MiPen:
            widthPoints = 1.5;
            break;
        case AnyBrushType_Fish:
            widthPoints = 1.2;
            break;
        case AnyBrushType_TiltPen:
            widthPoints = 4;
            break;
        case AnyBrushType_Spray:
            widthPoints = 5;
            break;
        case AnyBrushType_Crayon:
            widthPoints = 6;
            break;
        case AnyBrushType_Oil:
            widthPoints = 10;
            break;
            
        default:
            break;
    }
    return widthPoints;
}

#pragma mark - 主要绘图方法：

/**
 UIBezierPath过程
 */
static void DrawLayerCGPathApply(void * __nullable info, const CGPathElement *element) {
    AnyBitMap *bitMap = (__bridge AnyBitMap *)(info);
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: {
            bitMap.movePoint = points[0];
        }
            break;
        case kCGPathElementAddLineToPoint:      // contains 1 point
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
        case kCGPathElementAddCurveToPoint:     // contains 3 points
        {
            //长度估算
            CGFloat roughlyLength = ElementRoughlyLength(type, bitMap.movePoint, points);
            //宽度计算
            CGFloat lineWidth = LineWidth(bitMap.context, roughlyLength);
            //每个线宽N个点
            CGFloat widthPoints = PointsEachWidth(bitMap.context);
            //点之间距离
            CGFloat pointSpace = lineWidth/widthPoints;
            //此bezier上点个数
            CGFloat pointNum = MAX(roughlyLength/pointSpace, 1);
            
            //绘制
            for (NSInteger i = 0; i <= pointNum * 10; i++) {
                CGFloat t = i/(pointNum * 10);
                CGPoint point = tElementPoint(type, bitMap.movePoint, points, t);
                if (i == 1) {
                    if (!bitMap.hasFoundFirstPoint) {   //找到首点，首点不计长度，先画一个
                        bitMap.hasFoundFirstPoint = YES;
                        DrawPoint(bitMap, bitMap.lastPoint, point, lineWidth);
                    }
                }
                else if (i > 1) {
                    CGFloat length = sqrt(pow(bitMap.lastPoint.x - point.x, 2) + pow(bitMap.lastPoint.y - point.y, 2)) + bitMap.extraLength;
                    if (length >= pointSpace) {
                        DrawPoint(bitMap, bitMap.lastPoint, point, lineWidth);
                        bitMap.extraLength = 0;
                    }
                    else {
                        bitMap.extraLength = length;
                    }
                }
                bitMap.lastPoint = point;
            }
        }
            break;
        default:
            break;
    }
}

/**
 绘制点
 */
static void DrawPoint(AnyBitMap *bitMap, CGPoint lastPoint, CGPoint curruntPoint, CGFloat lineWidth) {
    CGContextSaveGState(bitMap.map);
    CGContextTranslateCTM(bitMap.map, curruntPoint.x, curruntPoint.y);
    if (bitMap.context.brushType == AnyBrushType_Fish ||
        bitMap.context.brushType == AnyBrushType_MiPen ||
        bitMap.context.brushType == AnyBrushType_Oil) {
        CGFloat rotate = atan2(curruntPoint.y - lastPoint.y, curruntPoint.x - lastPoint.x);
        CGContextRotateCTM(bitMap.map, rotate - M_PI_2);
    }
    CGRect rect = CGRectMake(-lineWidth/2, -lineWidth/2, lineWidth, lineWidth);
    CGContextDrawImage( bitMap.map, rect, bitMap.drawImage.CGImage );
    CGContextRestoreGState(bitMap.map);
}

/**
 bezier节点-->曲线大致长度
 */
static CGFloat ElementRoughlyLength(CGPathElementType type, CGPoint Point0, CGPoint *Points) {
    NSInteger sectionNum = 200;      //分段越多，长度越精确，但计算量越大。暂定200
    CGFloat length = 0;
    CGPoint previousPoint = Point0;
    switch (type) {
        case kCGPathElementAddLineToPoint:      //一个    直线就不用分段计算了
        {
            CGPoint Point1 = Points[0];
            length = sqrt(pow(Point0.x - Point1.x, 2) + pow(Point0.y - Point1.y, 2));
            return length;
        }
            break;
        case kCGPathElementAddQuadCurveToPoint: //两个
        case kCGPathElementAddCurveToPoint:     //三个
        {
            for (NSInteger i = 1; i <= sectionNum; i++) {
                CGFloat t = i/(CGFloat)sectionNum;
                CGPoint point = tElementPoint(type, Point0, Points, t);
                length += sqrt(pow(point.x - previousPoint.x, 2) + pow(point.y - previousPoint.y, 2));
                previousPoint = point;
            }
            return length;
        }
            
        default:
            return 0;
            break;
    }
}

/**
 在bezier上-->计算t处的Point值
 t范围为0.0-1.0
 
 一次：B = P0+(P1-P0)t
 二次：B = pow(1-t, 2)*P0 + 2t(1-t)*P1 + pow(t, 2)*P2
 三次：B = pow(1-t, 3)*P0 + 3t*pow(1-t, 2)*P1 + 3*pow(t, 2)*(1-t)*P2 + pow(t, 3)*P3
 */
static CGPoint tElementPoint(CGPathElementType type, CGPoint Point0, CGPoint *points, CGFloat t) {
    switch (type) {
        case kCGPathElementAddLineToPoint:      //一个
        {
            CGPoint Point1 = points[0];
            CGFloat Bx = Point0.x + (Point1.x - Point0.x) * t;
            CGFloat By = Point0.y + (Point1.y - Point0.y) * t;
            return CGPointMake(Bx, By);
        }
            break;
        case kCGPathElementAddQuadCurveToPoint: //两个
        {
            CGPoint Point1 = points[0];
            CGPoint Point2 = points[1];
            CGFloat Bx = pow(1-t, 2)*Point0.x + 2 * t * (1-t) * Point1.x + pow(t, 2) * Point2.x;
            CGFloat By = pow(1-t, 2)*Point0.y + 2 * t * (1-t) * Point1.y + pow(t, 2) * Point2.y;
            return CGPointMake(Bx, By);
        }
        case kCGPathElementAddCurveToPoint:     //三个
        {
            CGPoint Point1 = points[0];
            CGPoint Point2 = points[1];
            CGPoint Point3 = points[2];
            CGFloat Bx = pow(1-t, 3) * Point0.x + 3 * t * pow(1-t, 2) * Point1.x + 3 * pow(t, 2) * (1-t) * Point2.x + pow(t, 3) * Point3.x;
            CGFloat By = pow(1-t, 3) * Point0.y + 3 * t * pow(1-t, 2) * Point1.y + 3 * pow(t, 2) * (1-t) * Point2.y + pow(t, 3) * Point3.y;
            return CGPointMake(Bx, By);
        }
            break;
        default:
            return CGPointZero;
            break;
    }
}

- (UIImage *)drawImage {
    if (!_drawImage) {
        NSString *imageName = [AnyPublicMethod brushDrawImage:_context.brushType];
        UIImage *image = [UIImage imageNamed:imageName];
        _drawImage = [image imageWithColor:_context.strokeColor];
    }
    return _drawImage;
}

@end
