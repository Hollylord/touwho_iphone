//
//  WDSettingsViewController.m
//  ZBT
//
//  Created by 投壶 on 15/10/26.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDSettingsViewController.h"
#import "WDSettingsFooterView.h"
#import "WDForgetPassWordViewController.h"
#import "WDTabBarController.h"
#import "MBProgressHUD+MJ.h"
#import "WDInfoTool.h"

@interface WDSettingsViewController ()<WDSettingsFooterViewDelegate>

@end

@implementation WDSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = NO;

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    WDTabBarController * tabBar = (WDTabBarController *)self.tabBarController;
    tabBar.tabBar.hidden = YES;
    

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger integer =indexPath.row;
    int index = (int)integer;
    
    
    NSString * reuseIdentifier = [NSString stringWithFormat:@"settingsCell%d",index+1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 80;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
   WDSettingsFooterView * footerView = [[[NSBundle mainBundle] loadNibNamed:@"WDSettingsFooterView" owner:nil options:nil] lastObject];
    footerView.delegate = self;
    
    return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[[NSBundle mainBundle] loadNibNamed:@"WDSettingsHeaderView" owner:nil options:nil] lastObject];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:20];
    [whiteView setBackgroundColor:[UIColor grayColor]];
    
    [UIView animateWithDuration:0.2f animations:^{
        [whiteView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        
     //
        
        if(indexPath.row ==0 ){
            
            [MBProgressHUD showSuccess:@"已清空本地聊天记录和图片缓存"];
            NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString * plistPath = [caches stringByAppendingString:@"/Plist"];
            //先创建这个文件
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
            // 文件正确位置
            NSString *fileName = [plistPath stringByAppendingPathComponent:@"messages.plist"];
            [fileManager removeItemAtPath:fileName error:nil];
            
            
            //删除sdweb的图片
            NSString * imagePath = [caches stringByAppendingString:@"/default"];
            //先创建这个文件
            [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
            // 删除这个目录
            [fileManager removeItemAtPath:imagePath error:nil];
            
            
            
            // 发送一个清空本地聊天记录的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteMsg" object:self];
            
        }
        
        if(indexPath.row ==1 ){  // 修改密码
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WDForgetPassWordViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDForgetPassWordViewController"];
           // controller.hidesBottomBarWhenPushed = YES;
            [controller.navigationItem setTitle:@"修改密码"];
            [self.navigationController pushViewController:controller animated:YES];

        }
        
        if(indexPath.row ==2 ){
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"gongsijieshao"];
         //   controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        

        if(indexPath.row ==3 ){
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"guanyu"];
           // controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];

            
        }
        

        
        
        
        
        
        
        
        
       //
        
    }];
}


-(void)WDSettingsFooterViewQuit{
    // 把账户信息都删除了
    [WDInfoTool deleteAccountPlist];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
