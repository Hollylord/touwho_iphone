//
//  WDNewTopicViewContorller.m
//  ZBT
//
//  Created by 投壶 on 15/9/18.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDNewTopicViewContorller.h"
#import "WDCommunityOptView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载
#import "WDGroupModel.h" // 小组模型
#import "WDTopicDetailViewController.h"  //话题详情控制器
#import "WDInfoTool.h"  //获取沙盒的登录信息

#import "WDGroupTopicModel.h" //话题模型


@interface WDNewTopicViewContorller ()<WDCommunityOptViewDelegate>
@property(assign,nonatomic)BOOL isSelectedhuati;


//存放下拉的所有全部话题
@property (strong, nonatomic) NSMutableArray *allTopicArr;

//存放下拉的所有我参与的话题
@property (strong, nonatomic) NSMutableArray *allMyTopicArr;

@property(copy , nonatomic) NSString * showError; // 找不到我的小组和话提时提示


@end

@implementation WDNewTopicViewContorller

#pragma mark - 懒加载所有全部话题的总数量；
- (NSMutableArray *)allTopicArr{
    if (!_allTopicArr) {
        _allTopicArr = [NSMutableArray array];
    }
    return _allTopicArr;
}

#pragma mark - 懒加载 所有我参与的话题总数量；
- (NSMutableArray *)allMyTopicArr{
    if (!_allMyTopicArr) {
        _allMyTopicArr = [NSMutableArray array];
    }
    return _allMyTopicArr;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.isSelectedhuati = YES;
    self.showError = @"";  // 先设置为空
    
    
    
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
//    
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];

    
}


#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableView.footer endRefreshing];
    });
}



#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    
    //获取全部话题
    [self getAllTopicContent];
    
    //获取我的话题
    [self getAllMyTopicContent];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
    // });
}




#pragma mark -获取全部话题
-(void)getAllTopicContent{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    // 首先要获得最上面的窗口
    // UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:self.view];
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getTalks";
//    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
//    params[@"user_id"] = userID;
//    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功-getTalks-%@", responseObject);
         //成功以后我就进度条
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         // 先清空
         [self.allTopicArr removeAllObjects];
         
         NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         for (NSDictionary * dict in arry) {
             WDGroupTopicModel * model = [WDGroupTopicModel objectWithKeyValues:dict];
             model.mLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mLogo];
             [self.allTopicArr addObject:model];
         }
         
         
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"还未添加话题";
             [MBProgressHUD showError:str];
         }
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
}

#pragma mark -获取我的话题
-(void)getAllMyTopicContent{
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
    params[@"method"] = @"getMyTalks";
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    self.showError = @"";
    if ([userID isEqualToString:@""] || userID ==nil) {
        //[MBProgressHUD showError:@"未登录,无法获取用户参与的话题"];
        self.showError = @"未登录,无法获取用户参与的话题";
        return;        
    }
    params[@"user_id"] = userID;

    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功-getMyTalks-%@", responseObject);
         
         
         // 先清空
         [self.allMyTopicArr removeAllObjects];

         NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         for (NSDictionary * dict in arry) {
             WDGroupTopicModel * model = [WDGroupTopicModel objectWithKeyValues:dict];
             model.mLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mLogo];
             [self.allMyTopicArr addObject:model];
         }
         
//                  //成功
//                  if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
//                      NSString * str = @"加载成功";
//                      [MBProgressHUD showSuccess:str];
         
          //         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             //NSString * str = @"您还未参与任何话题";
             self.showError = @"您还未参与任何话题";
            // [MBProgressHUD showError:str];
         }
         
         
         // [MBProgressHUD hideHUDForView:window animated:YES];
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         //  [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
}



#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    if (self.isSelectedhuati == YES) {
        return self.allTopicArr.count;
    }
    
    return self.allMyTopicArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDNewTopicCell" forIndexPath:indexPath];
    
    WDGroupTopicModel * model = [[WDGroupTopicModel alloc] init];
    if (self.isSelectedhuati == YES) {
        model = self.allTopicArr[indexPath.row];
        // 设置头像
        UIImageView * icon = [cell viewWithTag:41];
        [icon sd_setImageWithURL:[NSURL URLWithString:model.mLogo] placeholderImage:[UIImage imageNamed:@"default_120"]];
        
        //话题标题
        UILabel * mShortTitle = [cell viewWithTag:43];
        [mShortTitle setText:model.mShortTitle];
        
        //话题来源于
        UILabel * mGroupName = [cell viewWithTag:44];
        [mGroupName setText:model.mGroupName];
        
        // 时间
        UILabel * mCreateTime = [cell viewWithTag:45];
        [mCreateTime setText:model.mCreateTime];
        
    }
    
    if (self.isSelectedhuati == NO) {
        model = self.allMyTopicArr[indexPath.row];
        // 设置头像
        UIImageView * icon = [cell viewWithTag:41];
        [icon sd_setImageWithURL:[NSURL URLWithString:model.mLogo] placeholderImage:[UIImage imageNamed:@"default_120"]];
        
        //话题标题
        UILabel * mShortTitle = [cell viewWithTag:43];
        [mShortTitle setText:model.mShortTitle];
        
        //话题来源于
        UILabel * mGroupName = [cell viewWithTag:44];
        [mGroupName setText:model.mGroupName];
        
        // 时间
        UILabel * mCreateTime = [cell viewWithTag:45];
        [mCreateTime setText:model.mCreateTime];

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 80;
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        WDCommunityOptView * view = (WDCommunityOptView *)[[[NSBundle mainBundle] loadNibNamed:@"WDCommunityOptView" owner:nil options:nil] lastObject];
        view.delegate = self;
        
        UIButton * btn1 = (UIButton *)[view viewWithTag:21];
        [btn1 setTitle:@"全部话题" forState:UIControlStateNormal];
        
        UIButton * btn2 = (UIButton *)[view viewWithTag:22];
        [btn2 setTitle:@"我参与的" forState:UIControlStateNormal];

        
        if (self.isSelectedhuati == YES) {
            [btn1 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOpt"] forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOptOrig"] forState:UIControlStateNormal];
        }
        if (self.isSelectedhuati == NO) {
            [btn1 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOptOrig"] forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOpt"] forState:UIControlStateNormal];

        }
        
     
        
        
        
        return view;
    }
    return nil;
    
}







#pragma  mark - WDCommunityOptViewDelegate
-(void)communitySelectedbtn1{
    self.isSelectedhuati = YES;
    
    NSIndexSet * indexSet = [[NSIndexSet alloc]initWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    
    
}
-(void)communitySelectedbtn2{
    if (![self.showError isEqualToString:@""]) {
        [MBProgressHUD showError:self.showError];
        self.showError = @"";
    }
    

        self.isSelectedhuati = NO;
    NSIndexSet * indexSet = [[NSIndexSet alloc]initWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:20];
    [whiteView setBackgroundColor:[UIColor grayColor]];
    
    WDGroupTopicModel * model = [[WDGroupTopicModel alloc] init];
    if (self.isSelectedhuati == YES) {
        model = self.allTopicArr[indexPath.row];
        
    }else{
        model = self.allMyTopicArr[indexPath.row];
        
    }

    
    
    [UIView animateWithDuration:0.2f animations:^{
        [whiteView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDTopicDetailViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDTopicDetailViewController"];
        controller.hidesBottomBarWhenPushed = YES;
        controller.topicModel = model;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

@end
