//
//  UIVideoDiscoverViewController.m
//  touwhoIphone
//
//  Created by 投壶 on 16/1/7.
//  Copyright © 2016年 投壶. All rights reserved.
//

#import "UIVideoDiscoverViewController.h"

@interface UIVideoDiscoverViewController ()

@end

@implementation UIVideoDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * btn = [[UIButton alloc] init];
    btn.frame = self.view.frame;
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(deleSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)deleSelf{
    NSLog(@"deleSelfdeleSelfdeleSelfdeleSelf");
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
