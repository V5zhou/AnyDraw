//
//  AnyDrawMainView.m
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "AnyDrawMainView.h"
#import "AnyCanvasView.h"
#import "AnyCanvasPicture.h"
#import "AnyBrushBox.h"
#import "AnyColorBox.h"

@interface AnyDrawMainView ()

//views
@property (weak, nonatomic) IBOutlet UIView *canvasBackView;
@property (weak, nonatomic) IBOutlet AnyCanvasView *canvasView;
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *brushBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *minWidth;
@property (weak, nonatomic) IBOutlet UILabel *maxWidth;
@property (weak, nonatomic) IBOutlet UIView *colorOutView;
@property (weak, nonatomic) IBOutlet UIButton *colorBtn;

//图片保存路径
@property (nonatomic, copy)   NSString *stepCachePath;      ///< 缓存步骤路径

//前进后退
@property (nonatomic, assign) NSInteger totalStep;          ///< 最大步骤
@property (nonatomic, assign) NSInteger curruntStep;        ///< 当前步骤

@property (nonatomic, copy)   NSString *canvasImageName;    ///< 当前画布背景图片名

@end

@implementation AnyDrawMainView

+ (instancetype)create {
    AnyDrawMainView *view = [[NSBundle mainBundle] loadNibNamed:@"AnyDrawMainView" owner:self options:nil][0];
    [view loadDefaultSetting];
    return view;
}

- (void)loadDefaultSetting {
    //设置底纹1
    _canvasImageName = @"画布1";
    _canvasBackView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:_canvasImageName].CGImage);
    
    //设置缓存路径
    NSString *localURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    localURL = [localURL stringByAppendingFormat:@"/StepCache/%lf", [[NSDate date] timeIntervalSince1970]];
    _stepCachePath = localURL;
    
    //设置默认圆珠笔
    kWeakSelf
    [_canvasView changeBrushType:AnyBrushType_BallPen finished:^(AnyContext *curruntContext){
        [weakSelf refreshView];
    }];
    
    //设置每一步的回调：使step加1、图片保存本地
    [_canvasView setStepCallBack:^(AnyPath *curruntPath, UIImage *canvasImage){
        //控制前进后退
        weakSelf.curruntStep++;
        weakSelf.totalStep = weakSelf.curruntStep;
        
        //存入本地
        [weakSelf cacheImage:canvasImage fileName:[NSString stringWithFormat:@"%0.4ld", weakSelf.curruntStep]];
    }];
}

#pragma mark - 按钮点击
- (IBAction)canvasImagePickClick:(id)sender {
    kWeakSelf
    [AnyCanvasPicture showWithCurruntImageName:_canvasImageName selectAction:^(NSString *imageName) {
        weakSelf.canvasImageName = imageName;
        weakSelf.canvasBackView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:imageName].CGImage);
    }];
}

- (IBAction)previousClick:(id)sender {
    if (_curruntStep < 1) {
        [SVProgressHUD showInfoWithStatus:@"已回退到最前"];
    }
    else {
        _curruntStep--;
        self.canvasView.layer.contents = (__bridge id _Nullable)([self imageAtStep:_curruntStep].CGImage);
    }
}

- (IBAction)nextClick:(id)sender {
    if (_curruntStep >= _totalStep) {
        [SVProgressHUD showInfoWithStatus:@"无更多下一步"];
    }
    else {
        _curruntStep++;
        self.canvasView.layer.contents = (__bridge id _Nullable)([self imageAtStep:_curruntStep].CGImage);
    }
}

- (IBAction)clearClick:(id)sender {
    self.curruntStep = 0;
    self.totalStep = 0;
    self.canvasView.layer.contents = nil;
    //删除所有本地缓存
    [self deleteAllCaches];
}

- (IBAction)saveClick:(id)sender {
    if (_curruntStep == 0) {
        [SVProgressHUD showInfoWithStatus:@"暂无步骤"];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在保存图片"];
    UIImage *image = [_canvasBackView screenShot];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存图片失败"];
    }
    else {
        [SVProgressHUD showSuccessWithStatus:@"保存图片成功"];
    }
}

- (IBAction)brushClick:(id)sender {
    kWeakSelf
    [AnyBrushBox showWithSelectAction:^(AnyBrushType brushType) {
        [weakSelf.canvasView changeBrushType:brushType finished:^(AnyContext *curruntContext) {
            [weakSelf refreshView];
        }];
    }];
}

- (IBAction)colorClick:(id)sender {
    kWeakSelf
    [AnyColorBox showWithType:ColorPickerType_Default color:_canvasView.curruntContext.strokeColor selectAction:^(UIColor *color) {
        weakSelf.canvasView.curruntContext.strokeColor = color;
        [weakSelf refreshView];
    }];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    _canvasView.curruntContext.lineWidth = slider.value;
}

#pragma mark - 图片缓存
//缓存图片
- (void)cacheImage:(UIImage *)image fileName:(NSString *)fileName {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *filePath = [self.stepCachePath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.stepCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.stepCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if ([imageData writeToFile:filePath atomically:YES]) {
        NSLog(@"保存成功--%ld", _curruntStep);
    }
}

//删除所有缓存图片
- (void)deleteAllCaches {
    NSString *localURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    localURL = [localURL stringByAppendingFormat:@"/StepCache"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:localURL];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[localURL stringByAppendingPathComponent:fileName] error:nil];
    }
}

- (UIImage *)imageAtStep:(NSInteger)step {
    if (step < 0) {
        return nil;
    }
    NSString *filePath = [self.stepCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%0.4ld", step]];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    return image;
}

//页面刷新
- (void)refreshView {
    AnyContext *curruntContext = self.canvasView.curruntContext;
    
    [self.brushBtn setBackgroundImage:[UIImage imageNamed:[AnyPublicMethod brushSelectedImage:curruntContext.brushType]] forState:UIControlStateNormal];
    self.minWidth.text = [NSString stringWithFormat:@"%.2f", curruntContext.minWidth];
    self.maxWidth.text = [NSString stringWithFormat:@"%.2f", curruntContext.maxWidth];
    self.slider.minimumValue = curruntContext.minWidth;
    self.slider.maximumValue = curruntContext.maxWidth;
    self.slider.value = curruntContext.lineWidth;
    self.colorBtn.backgroundColor = curruntContext.strokeColor;
    self.colorBtn.userInteractionEnabled = (curruntContext.brushType != AnyBrushType_Eraser);
    
    self.colorOutView.layer.borderColor = curruntContext.strokeColor.CGColor;
}

@end
