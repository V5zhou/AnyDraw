//
//  AnyColorBox.m
//  AnyDraw
//
//  Created by zmz on 2017/10/9.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyColorBox.h"

@interface AnyColorCell : UICollectionViewCell

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIColor *color;

@end

@implementation AnyColorCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = CGRectGetWidth(frame)/2;
        
        //
        CGFloat offset = 4;
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(offset, offset, CGRectGetWidth(frame) - offset * 2, CGRectGetWidth(frame) - offset * 2)];
        _mainView.layer.cornerRadius = CGRectGetWidth(self.mainView.frame)/2;
        [self addSubview:_mainView];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.layer.borderColor = color.CGColor;
    self.mainView.backgroundColor = color;
}

@end

@interface AnyColorBox ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) ColorPickerType type;
@property (nonatomic, copy)   UIColor *selectColor;
@property (nonatomic, copy)   void (^selectAction)(UIColor *color);

@property (nonatomic, strong) UIScrollView *mainView;
@property (nonatomic, strong) UIView *selectColorView;
@property (nonatomic, strong) UIPageControl *pageCtl;
@property (nonatomic, assign) CGFloat imageScale;

@end

@implementation AnyColorBox

+ (instancetype)showWithType:(ColorPickerType)type color:(UIColor *)color selectAction:(void (^)(UIColor *))selectAction {
    AnyColorBox *box = [[AnyColorBox alloc] initWithFrame:[UIScreen mainScreen].bounds];
    box.type = type;
    box.selectColor = color;
    box.selectAction = selectAction;
    box.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [box createMainView];
    [box showView];
    return box;
}

//创建主页面
- (void)createMainView {
    self.mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH - 40, 200)];
    _mainView.center = self.center;
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.contentSize = CGSizeMake((kSCREEN_WIDTH - 40)*2, 100);
    _mainView.pagingEnabled = YES;
    _mainView.layer.cornerRadius = 4;
    _mainView.layer.masksToBounds = YES;
    _mainView.delegate = self;
    [self addSubview:_mainView];
    
    self.pageCtl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 180, kSCREEN_WIDTH, 20)];
    _pageCtl.center = CGPointMake(self.center.x, self.center.y + 90);
    _pageCtl.numberOfPages = 2;
    _pageCtl.currentPage = 0;
    _pageCtl.pageIndicatorTintColor = RGBHEX_(#e5e5e5);
    _pageCtl.currentPageIndicatorTintColor = RGBHEX_(#666666);
    [self addSubview:_pageCtl];
    
    //颜色选择器类型
    [_mainView setContentOffset:CGPointMake((kSCREEN_WIDTH - 40) * _type, 0)];
    
    NSInteger eachlineNum = 6;
    CGFloat cubeW = (kSCREEN_WIDTH - 40 - 10 * (eachlineNum + 1))/eachlineNum;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(cubeW, cubeW);
    flow.minimumLineSpacing = 10;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH - 40, 200) collectionViewLayout:flow];
    collection.backgroundColor = RGBHEX_(#f4f4f4);
    collection.delegate = self;
    collection.dataSource = self;
    [self.mainView addSubview:collection];
    [collection registerClass:[AnyColorCell class] forCellWithReuseIdentifier:@"AnyColorCell"];
    
    //调色板
    CGFloat H = 160;
    CGFloat W = H * 997.0/713.0;
    UIImage *image = [UIImage imageNamed:@"调色板.jpg"];
    self.imageScale = image.size.height/H;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH - 40, 0, W, H)];
    imageView.image = image;
    imageView.userInteractionEnabled = YES;
    [self.mainView addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [imageView addGestureRecognizer:tap];
    
    _selectColorView = [self.mainView createView:CGRectMake(kSCREEN_WIDTH - 40 + 40, 165, 30, 30) backColor:_selectColor];
    
    kWeakSelf
    UIButton *cancel = [self.mainView createButton:CGRectMake((kSCREEN_WIDTH - 40) * 2 - 100, 165, 30, 30) imageName:nil font:[UIFont systemFontOfSize:12] color:RGBHEX_(#666666) backColor:nil text:@"取消"];
    [cancel setsAction:^(UIButton *button) {
        [weakSelf hiddenView];
    }];

    UIButton *convert = [self.mainView createButton:CGRectMake((kSCREEN_WIDTH - 40) * 2 - 60, 165, 30, 30) imageName:nil font:[UIFont systemFontOfSize:12] color:RGBHEX_(#333333) backColor:nil text:@"确定"];
    [convert setsAction:^(UIButton *button) {
        if (weakSelf.selectAction) {
            weakSelf.selectAction(weakSelf.selectColor);
        }
        [weakSelf hiddenView];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [DefaultColors() count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AnyColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnyColorCell" forIndexPath:indexPath];
    UIColor *color = DefaultColors()[indexPath.item];
    cell.color = color;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color = DefaultColors()[indexPath.item];
    if (_selectAction) {
        _selectAction(color);
    }
    [self hiddenView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    _pageCtl.currentPage = (*targetContentOffset).x/scrollView.frame.size.width;
}

#pragma mark - 调色板滑动
- (void)tapGesture:(UIPanGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:tap.view];
    point = CGPointApplyAffineTransform(point, CGAffineTransformMakeScale(_imageScale, _imageScale));
    UIImage *image = [UIImage imageNamed:@"调色板.jpg"];
    self.selectColor = [image pixColorAtPoint:point];
    _selectColorView.backgroundColor = _selectColor;
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

//预设颜色
static NSArray *DefaultColors() {
    return @[
             [UIColor colorWithHex:0x142522 andAlpha:0.8],
             [UIColor colorWithHex:0xe93e47 andAlpha:0.8],
             [UIColor colorWithHex:0xe27555 andAlpha:0.8],
             [UIColor colorWithHex:0xfce1dd andAlpha:0.8],
             [UIColor colorWithHex:0x55af6c andAlpha:0.8],
             [UIColor colorWithHex:0x97e5d0 andAlpha:0.8],
             
             [UIColor colorWithHex:0xf7ae3a andAlpha:0.8],
             [UIColor colorWithHex:0xfbf14f andAlpha:0.8],
             [UIColor colorWithHex:0xb9da5b andAlpha:0.8],
             [UIColor colorWithHex:0x0f6bb4 andAlpha:0.8],
             [UIColor colorWithHex:0x20b0dc andAlpha:0.8],
             [UIColor colorWithHex:0x8dd1e7 andAlpha:0.8],
             
             [UIColor colorWithHex:0x42125c andAlpha:0.8],
             [UIColor colorWithHex:0x911587 andAlpha:0.8],
             [UIColor colorWithHex:0xe76ba1 andAlpha:0.8],
             [UIColor colorWithHex:0x584baf andAlpha:0.8],
             [UIColor colorWithHex:0x5782a6 andAlpha:0.8],
             [UIColor colorWithHex:0xffffff andAlpha:0.8],
             ];
}

@end
