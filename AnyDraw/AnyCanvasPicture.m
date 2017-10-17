//
//  AnyCanvasPicture.m
//  AnyDraw
//
//  Created by zmz on 2017/10/11.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyCanvasPicture.h"

@interface CanvasPictureCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *indexLabel;  //显示图片是第几张

@property (nonatomic, copy)   NSString *imageName;

@end

@implementation CanvasPictureCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.contentsGravity = kCAGravityResizeAspect;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(-2, -3);
        self.layer.shadowOpacity = 0.8;
        
        self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _indexLabel.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        _indexLabel.textColor = RGBHEX_(#6ecbf3);
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:_indexLabel];
    }
    return self;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = [imageName copy];
    self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:imageName].CGImage);
    self.indexLabel.text = imageName;
}

@end

@interface AnyCanvasPicture () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy)   void (^selectAction)(NSString *imageName);
@property (nonatomic, strong) NSMutableArray<NSString *> *imageNames;
@property (nonatomic, copy)   NSString *defaultImageName;

@end

@implementation AnyCanvasPicture

/**
 创建
 */
+ (instancetype)showWithCurruntImageName:(NSString *)imageName selectAction:(void(^)(NSString *imageName))selectAction {
    AnyCanvasPicture *picture = [[AnyCanvasPicture alloc] initWithFrame:[UIScreen mainScreen].bounds];
    picture.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    picture.defaultImageName = imageName;
    picture.selectAction = selectAction;
    [picture createMainView];
    [picture showView];
    return picture;
}

//创建主页面
- (void)createMainView {
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(kSCREEN_WIDTH - 40, kSCREEN_HEIGHT - 100);
    flow.minimumLineSpacing = 40;
    flow.minimumInteritemSpacing = 40;
    flow.sectionInset = UIEdgeInsetsMake(50, 20, 50, 20);
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection.backgroundColor = [UIColor clearColor];
    collection.center = self.center;
    collection.delegate = self;
    collection.dataSource = self;
    collection.pagingEnabled = YES;
    [self addSubview:collection];
    [collection registerClass:[CanvasPictureCell class] forCellWithReuseIdentifier:@"CanvasPictureCell"];
    //滚动到对应页
    NSInteger index = [self.imageNames indexOfObject:_defaultImageName];
    if (index != NSNotFound) {
        [collection setContentOffset:CGPointMake(kSCREEN_WIDTH * (index + self.imageNames.count), 0) animated:NO];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageNames.count * 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CanvasPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CanvasPictureCell" forIndexPath:indexPath];
    NSString *name = self.imageNames[indexPath.item%self.imageNames.count];
    cell.imageName = name;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = self.imageNames[indexPath.item%self.imageNames.count];
    if (_selectAction) {
        _selectAction(name);
    }
    [self hiddenView];
}

//无限滚动控制
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self makeLoopScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self makeLoopScroll:scrollView];
}

- (void)makeLoopScroll:(UIScrollView *)scrollView {
    NSInteger scrollIndex = (NSInteger)(scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame));
    if (scrollIndex > 2 * _imageNames.count - 1 ||
        scrollIndex < _imageNames.count) {
        [scrollView setContentOffset:CGPointMake(kSCREEN_WIDTH * (scrollIndex%_imageNames.count + _imageNames.count), 0) animated:NO];
    }
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

#pragma mark - 画布背景图
- (NSMutableArray<NSString *> *)imageNames {
    if (!_imageNames) {
        _imageNames = [NSMutableArray array];
        [_imageNames addObject:@"无画布"];
        for (NSInteger i = 0; i < 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"画布%ld", i + 1];
            [_imageNames addObject:imageName];
        }
    }
    return _imageNames;
}

@end
