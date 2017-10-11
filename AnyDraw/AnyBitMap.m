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
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) UIImage *drawImage;

@end

@implementation AnyBitMap

+ (instancetype)createWithSize:(CGSize)size context:(AnyContext *)context {
    AnyBitMap *bitMap = [[AnyBitMap alloc] init];
    bitMap.context = context;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    bitMap.map = CGBitmapContextCreate(NULL,
                                    size.width,
                                    size.height,
                                    8,
                                    4 * size.width,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(bitMap.map, 0, size.height);
    CGContextScaleCTM(bitMap.map, 1.0, -1.0);
    CGColorSpaceRelease( colorSpace );
    
    return bitMap;
}

- (void)endBitMap {
    if (self.map) {
        CGContextRelease(self.map);
    }
}

- (UIImage *)addBezier:(UIBezierPath *)bezier {
    CGPathApply(bezier.CGPath, (__bridge void * _Nullable)(self), DrawLayerCGPathApply);
    
    //取出图片
    CGImageRef cgImage = CGBitmapContextCreateImage(self.map);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
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
        {
            CGFloat maxWidth = lineWidth;
            CGFloat minWidth = lineWidth/3; //笔画画最快时，最小宽度限制。免得细的看不到了
            lineWidth = minWidth + (maxWidth - minWidth) * (20/MAX(20, pathLength));
        }
            break;
            
        default:
            break;
    }
    return lineWidth;
}


/**
 一个bezier区间的分段段数
 因为绘制方式为小方格绘制在分段点point上，小方格size = (lineWidth, lineWidth)，有多少个分段点就有多少个小方格。
 不能让路径出现断裂，所以在线宽不同时，对应的间距也要做调整。
 */
static NSInteger Sections(AnyContext *context, CGFloat roughlyLength, CGFloat lineWidth) {
    NSInteger sections = (int)(roughlyLength*4/lineWidth) + 1;  //每段长度为线宽的4分之1
    switch (context.brushType) {
        case AnyBrushType_MiPen: {
            sections = (int)(roughlyLength*1/lineWidth) + 1;    //米字就一个线宽一个米字
        }
            break;
            
        default:
            break;
    }
    return sections;
}

#pragma mark - 主要绘图方法：

/**
 UIBezierPath过程
 */
static void DrawLayerCGPathApply(void * __nullable info, const CGPathElement *element) {
    AnyBitMap *bitMap = (__bridge AnyBitMap *)(info);
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    //长度估算
    CGFloat roughlyLength = ElementRoughlyLength(type, bitMap.lastPoint, points);
    
    //宽度计算
    CGFloat lineWidth = LineWidth(bitMap.context, roughlyLength);
    
    //分段数
    NSInteger sections = Sections(bitMap.context, roughlyLength, lineWidth);
    
    switch(type) {
        case kCGPathElementMoveToPoint: {
            bitMap.lastPoint = points[0];
        }
            break;
        case kCGPathElementAddLineToPoint:      // contains 1 point
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
        case kCGPathElementAddCurveToPoint:     // contains 3 points
        {
            for (NSInteger i = 1; i <= sections; i++) {
                CGFloat t = i/(CGFloat)sections;
                CGPoint point = tElementPoint(type, bitMap.lastPoint, points, t);
                CGRect rect = CGRectMake(point.x - lineWidth/2, point.y - lineWidth/2, lineWidth, lineWidth);
                CGContextDrawImage( bitMap.map, rect, bitMap.drawImage.CGImage );
            }
        }
            break;
        default:
            break;
    }
}

/**
 bezier节点-->曲线大致长度
 */
static CGFloat ElementRoughlyLength(CGPathElementType type, CGPoint Point0, CGPoint *Points) {
    NSInteger sectionNum = 20;      //分段越多，长度越精确，但计算量越大。暂定20
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
