//
//  ViewController.m
//  AnyDraw
//
//  Created by zmz on 2017/9/29.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "ViewController.h"
#import "AnyDrawMainView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AnyDrawMainView *view = [AnyDrawMainView create];
    view.frame = self.view.bounds;
    [self.view addSubview:view];
}

@end
