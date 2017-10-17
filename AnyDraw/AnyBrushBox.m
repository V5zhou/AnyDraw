//
//  AnyBrushBox.m
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyBrushBox.h"

@interface BrushBoxCell : UICollectionViewCell

@end

@implementation BrushBoxCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBHEX_(#f4f4f4);
        self.layer.contentsGravity = kCAGravityResizeAspect;
    }
    return self;
}

@end

@interface AnyBrushBox ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *mainCollection;
@property (nonatomic, copy)   void (^selectAction)(AnyBrushType brushType);

@end

@implementation AnyBrushBox

/**
 显示
 */
+ (instancetype)showWithSelectAction:(void(^)(AnyBrushType brushType))selectAction {
    AnyBrushBox *box = [[AnyBrushBox alloc] initWithFrame:[UIScreen mainScreen].bounds];
    box.selectAction = selectAction;
    box.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [box createMainView];
    [box showView];
    return box;
}

//创建主页面
- (void)createMainView {
    CGFloat cubeH = 50;
    CGFloat cubeW = (kSCREEN_WIDTH - 40 - 30)/2;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(cubeW, cubeH);
    flow.minimumLineSpacing = 10;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    NSInteger limitLine = 6;
    NSInteger line = MIN(limitLine, [Brushs() count]/2 + ([Brushs() count]%2 != 0));
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH - 40, line * (cubeH + 10) + 10) collectionViewLayout:flow];
    collection.center = self.center;
    collection.backgroundColor = [UIColor whiteColor];
    collection.layer.cornerRadius = 4;
    collection.alwaysBounceVertical = YES;
    collection.delegate = self;
    collection.dataSource = self;
    [self addSubview:collection];
    [collection registerClass:[BrushBoxCell class] forCellWithReuseIdentifier:@"BrushBoxCell"];
    self.mainCollection = collection;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Brushs() count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BrushBoxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrushBoxCell" forIndexPath:indexPath];
    AnyBrushType brushType = [Brushs()[indexPath.item] integerValue];
    NSString *imageName = [AnyPublicMethod brushCubeImage:brushType];
    UIImage *image = [UIImage imageNamed:imageName];
    cell.layer.contents = (__bridge id _Nullable)(image.CGImage);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AnyBrushType type = [Brushs()[indexPath.item] integerValue];
    if (_selectAction) {
        _selectAction(type);
    }
    [self hiddenView];
}

#pragma mark - 显示与隐藏
- (void)showView {
    self.alpha = 0;
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hiddenView {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view == self) {
        [self hiddenView];
    }
}

static NSArray *Brushs() {
    return @[
             @(AnyBrushType_BallPen),
             @(AnyBrushType_TiltPen),
             @(AnyBrushType_MiPen),
             @(AnyBrushType_Spray),
             @(AnyBrushType_Fish),
             @(AnyBrushType_Eraser),
             @(AnyBrushType_Crayon),
             @(AnyBrushType_Oil),
             ];
}

@end
