//
//  WDGroupDetailViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/21.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDGroupDetailViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "WDInfoTool.h"  //获取沙盒的登录信息
#import "WDGroupTopicModel.h"   // 小组下的话题模型
#import "WDTopicDetailViewController.h"



@interface WDGroupDetailViewController ()
@property (assign,nonatomic)BOOL isAddGroup;
//存放下拉的所有热门话题
@property (strong, nonatomic) NSMutableArray *allTopArr;


@end

@implementation WDGroupDetailViewController

#pragma mark - 懒加载小组下的话题的总数量；
- (NSMutableArray *)allTopArr{
    if (!_allTopArr) {
        _allTopArr = [NSMutableArray array];
    }
    return _allTopArr;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
   NSLog(@"刚进来的时候-%@",self.groupModel.mIsInGroup);
    NSLog(@"刚进来的时候-%@",self.groupModel.mLogo);


    if ([self.groupModel.mIsInGroup isEqualToString:@"0"]) {  // 0就是不在这个小组里
        self.isAddGroup = YES;
    }else{
        self.isAddGroup = NO;
    }
    
    
    
    //
    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
//    // 下拉刷新
//    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
//    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [weakSelf loadMoreData];
//    }];
    
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
}





//#pragma mark 上拉加载更多数据
//- (void)loadMoreData
//{
//    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 刷新表格
//        [self.tableView reloadData];
//        
//        // 拿到当前的上拉刷新控件，结束刷新状态
//        [self.tableView.footer endRefreshing];
//    });
//}
//
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
    params[@"group_id"] = self.groupModel.mID;
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

        
        
        
        // 先清空
        [self.allTopArr removeAllObjects];
        
        NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"mTalks"];
        
        for (NSDictionary * dict in arry) {
            WDGroupTopicModel * model = [WDGroupTopicModel objectWithKeyValues:dict];
            model.mLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mLogo];
            [self.allTopArr addObject:model];
        }
        

//        //成功
//        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
////              NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
//             [MBProgressHUD showSuccess:str];
//            
//        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        // 请求完毕后刷新
        NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
       // [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        
    }];


}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
        return 1;
    }
    return self.allTopArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDGroupChatCell" forIndexPath:indexPath];
        WDGroupTopicModel * topicModel = self.allTopArr[indexPath.row];

        // 设置头像
        UIImageView * icon = [cell viewWithTag:21];
        [icon sd_setImageWithURL:[NSURL URLWithString:topicModel.mLogo] placeholderImage:[UIImage imageNamed:@"default_120"]];

        //小组名称
        UILabel * groupName = [cell viewWithTag:22];
        [groupName setText:topicModel.mShortTitle];

        //小组成员数量
        UILabel * mCommentCount = [cell viewWithTag:23];
        [mCommentCount setText:topicModel.mCommentCount];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WDGroupCardCell" forIndexPath:indexPath];

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
    [icon sd_setImageWithURL:[NSURL URLWithString:self.groupModel.mLogo] placeholderImage:[UIImage imageNamed:@"default_120"]];
    
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 250;
    }
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:20];
    [whiteView setBackgroundColor:[UIColor grayColor]];
    
    
    
    
    [UIView animateWithDuration:0.2f animations:^{
        [whiteView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDTopicDetailViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDTopicDetailViewController"];
        controller.hidesBottomBarWhenPushed = YES;
        controller.topicModel = self.allTopArr[indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
        
    }];

}


@end
