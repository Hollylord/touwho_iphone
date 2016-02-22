//
//  WDTopicShowCardViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/22.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDTopicShowCardViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载
#import "WDActivityDetalController.h"

#import "WDGroupModel.h" // 小组模型
#import "WDGroupDetailViewController.h" //小组详情控制器
#import "WDInfoTool.h"  //获取沙盒的登录信息


@interface WDTopicShowCardViewController ()
@property (assign,nonatomic)BOOL isAddGroup;
@property (strong ,nonatomic) WDGroupModel * groupModel;


@end

@implementation WDTopicShowCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //
    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];

    
    
//    
//    
//    
//    
//    if ([self.groupModel.mIsInGroup isEqualToString:@"0"]) {  // 0就是不在这个小组里
//        self.isAddGroup = YES;
//    }else{
//        self.isAddGroup = NO;
//    }
//    
    
    
    
    
}
#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    // 请求小组详情；
    [self requestGroupDetailContent];
    
    //[self.tableView reloadData];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
    // });
}


#pragma mark - 请求小组详情
- (void)requestGroupDetailContent {
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    //    // 首先要获得最上面的窗口
    //    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    //
    //    //设置进度条；
    //    [MBProgressHUD showMessage:@"正在加载" toView:window];
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getDetailGroup";
    params[@"group_id"] = self.topicDetail.mGroupID;
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    params[@"user_id"] = userID;
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        // NSLog(@"请求成功-requestGroupDetailContent-%@", responseObject);
        //成功以后我就进度条
        // [MBProgressHUD hideHUDForView:window animated:YES];
        
        // 更新一下本页的数据model
        NSDictionary * dict = [[responseObject objectForKey:@"value"] firstObject];
        WDGroupModel * model = [WDGroupModel objectWithKeyValues:dict];
        model.mLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mLogo];
        self.groupModel = model;
        
        NSLog(@"self.groupModel.mIsInGroup--%@",self.groupModel.mIsInGroup);
        NSLog(@"self.groupModel.mIsInGroup--%@",self.groupModel.mLogo);
        
        
        if ([self.groupModel.mIsInGroup isEqualToString:@"0"]) {  // 0就是不在这个小组里
            self.isAddGroup = YES;
        }else{
            self.isAddGroup = NO;
        }
        
                //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        // 请求完毕后刷新
        NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
        // [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        
    }];
    
    
}





#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDGroupCardCell" forIndexPath:indexPath];
    // 设置按钮【加入小组】
    UIButton * btn = (UIButton *)[cell viewWithTag:26];
    [btn addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.isAddGroup == YES) {
        [btn setTitle:@"加入小组" forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"退出小组" forState:UIControlStateNormal];
    }
    
    // 设置头像
    UIImageView * icon = [cell viewWithTag:21];
    [icon sd_setImageWithURL:[NSURL URLWithString:self.groupModel.mLogo] placeholderImage:[UIImage imageNamed:@"default_icon"]];
    
    //小组名称
    UILabel * groupName = [cell viewWithTag:22];
    [groupName setText:self.groupModel.mName];
    
    //小组简介
    UILabel * destrible = [cell viewWithTag:23];
    NSString * des = [NSString stringWithFormat:@"简介:%@",self.groupModel.mDestrible];
    [destrible setText:des];
    
    //组长
    UILabel * mGroupLeader = [cell viewWithTag:24];
    [mGroupLeader setText:self.groupModel.mGroupLeader];
    
    
    //小组成员数量
    UILabel * menberCount = [cell viewWithTag:25];
    [menberCount setText:self.groupModel.mMemberCount];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
}



-(void)addGroup:(UIButton *)btn{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    
    
    if (self.isAddGroup == YES) { //  不在这里小组里
        
        // 1.创建一个请求操作管理者
        AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
        
        //加载网络数据
        // 2.请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"method"] = @"addGroup";
        params[@"group_id"] = self.groupModel.mID;
        params[@"user_id"] = userID;
        // 3.发送一个GET请求
        NSString *url = @"http://120.25.215.53:8099/api.aspx";
        //NSString * SERVER_URL = @"http://120.25.215.53:8099";
        
        [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            // 请求成功的时候调用这个block
            //    NSLog(@"请求成功-requestGroupDetailContent-%@", responseObject);
            
            //成功
            if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
                NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
                [MBProgressHUD showSuccess:str];
                
                self.isAddGroup = NO;
                [btn setTitle:@"退出小组" forState:UIControlStateNormal];
            }
            //失败
            
            if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
                NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
                [MBProgressHUD showError:str];
            }
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            // 请求失败的时候调用调用这个block
            NSLog(@"请求失败");
            [MBProgressHUD showError:@"网络连接错误"];
        }];
        
        
        
    }
    
    if (self.isAddGroup == NO)
    {                        // 在这个小组里
        
        
        // 1.创建一个请求操作管理者
        AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
        
        //加载网络数据
        // 2.请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"method"] = @"exitGroup";
        params[@"group_id"] = self.groupModel.mID;
        params[@"user_id"] = userID;
        // 3.发送一个GET请求
        NSString *url = @"http://120.25.215.53:8099/api.aspx";
        //NSString * SERVER_URL = @"http://120.25.215.53:8099";
        
        [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            // 请求成功的时候调用这个block
            NSLog(@"请求成功-requestGroupDetailContent-%@", responseObject);
            
            //成功
            if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
                NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
                [MBProgressHUD showSuccess:str];
                
                self.isAddGroup = YES;
                [btn setTitle:@"加入小组" forState:UIControlStateNormal];
                
            }
            //失败
            
            if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
                NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
                [MBProgressHUD showError:str];
            }
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            // 请求失败的时候调用调用这个block
            NSLog(@"请求失败");
            [MBProgressHUD showError:@"网络连接错误"];
        }];
        
        
    }
    
    
}



@end
