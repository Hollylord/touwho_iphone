//
//  BTNewsDetailViewController.m
//  touwhoIphone
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 投壶. All rights reserved.


#import "BTNewsDetailViewController.h"

@interface BTNewsDetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BTNewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"url = %@",self.URL);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URL]];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



@end
