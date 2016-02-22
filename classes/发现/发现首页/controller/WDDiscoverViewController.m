//
//  WDDiscoverViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/10.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDDiscoverViewController.h"
#import "WDTabBarController.h"
#import "RootViewController.h"  // 新版语音

#import "MBProgressHUD+MJ.h"
#import "WDInfoTool.h"


@interface WDDiscoverViewController ()

- (IBAction)btn1:(UIButton *)sender;

- (IBAction)btn2:(UIButton *)sender;
- (IBAction)btn3:(UIButton *)sender;

@end

@implementation WDDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//
//-(void)viewWillAppear:(BOOL)animated{
//    
//    tabViewController * tab =(tabViewController *)self.tabBarController;
//    
//    
//    if ( tab.customTabBar.hidden == YES) {
//        
//        CGFloat currentWidth = [[UIScreen mainScreen] bounds].size.width;
//        CGRect frame;
//        if (currentWidth > 375) {
//            frame = CGRectMake(0, 736, 414, 61);
//        }
//        
//        if( currentWidth <= 375 && currentWidth > 320 ){
//            frame = CGRectMake(0, 667, 375, 61);
//        }
//        
//        if( currentWidth <= 320){
//            frame = CGRectMake(0, 568, 320, 61);
//        }
//        
//        
//        tab.customTabBar.frame  = frame;
//        tab.customTabBar.hidden = NO;
//        
//        
//        if (currentWidth > 375) {
//            frame = CGRectMake(0, 675, 414, 61);
//        }
//        
//        if( currentWidth <= 375 && currentWidth > 320 ){
//            frame = CGRectMake(0, 606, 375, 61);
//        }
//        
//        if( currentWidth <= 320){
//            frame = CGRectMake(0, 507, 320, 61);
//        }
//        
//        
//        
//        [UIView animateWithDuration:0.25f animations:^{
//            tab.customTabBar.frame  = frame;
//        } completion:^(BOOL finished) {
//            
//        }];
//        
//    }
//    
//}
//

- (IBAction)btn1:(UIButton *)sender {
   // UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"yuyin"];
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    RootViewController * controller = [[RootViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.tag_ID = @"66";
    controller.userID = userID;
    [self.navigationController pushViewController:controller animated:YES];

    
    
}

- (IBAction)btn2:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDActivityListViewController"];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];

    
    
}

- (IBAction)btn3:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDVideoTableView"];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];

    
    
}
-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    if (tab.tabBar.hidden == YES) {
        tab.tabBar.hidden = NO;
    }
}

@end
