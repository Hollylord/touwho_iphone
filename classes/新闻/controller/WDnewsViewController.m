//
//  WDnewsViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDnewsViewController.h"
#import "WDTabBarController.h"
#import <AFNetworking.h>
#import "MJRefresh.h"
#import "WDNewsDetailViewController.h"
#import "MBProgressHUD+MJ.h"
#import "newsContent.h"

#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "TalkingData.h" // talkdata


@interface WDnewsViewController ()

//存放下拉的所有新闻模型
@property (strong, nonatomic) NSMutableArray *allNewsArr;

// 存放new_id
@property (copy,nonatomic) NSString * newsID;


@end

@implementation WDnewsViewController


#pragma mark - 懒加载 加载新闻的总数量；
- (NSMutableArray *)allNewsArr{
    if (!_allNewsArr) {
        _allNewsArr = [NSMutableArray array];
    }
    return _allNewsArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 去掉分割线
    self.tableView.separatorStyle = NO;

    // 设置new_id的为0，因为第一次规定为0
    self.newsID = @"0";
    

    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 下拉刷新
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];

    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.header beginRefreshing];
//
//    });

}


#pragma mark 获取往期新闻 上拉
- (void)loadMoreData
{
    
    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
//    [MBProgressHUD showMessage:@"正在请求" toView:window];

    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getNewsTitle_Next";
    
    params[@"news_id"] = self.newsID;
    
    if(self.allNewsArr.count > 0){
        // 这里是下拉刷新 所以数值不能改变，只能往后面加进去 获取往期的新闻
        // 拿到距离现在时间最远的newID ,也就是当前的最后一个;(因为现在要拿距离更加远的)
        newsContent * lastModel = [self.allNewsArr lastObject];
        self.newsID = lastModel.mID;
        params[@"news_id"] = self.newsID;
    }
    
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功--%@", responseObject);
         
         //成功以后我就进度条
       //  [MBProgressHUD hideHUDForView:window animated:YES];
         
         
         //获得新闻数组
         NSArray *newsList = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         for (NSDictionary *dict in newsList) {
             newsContent * model =  [newsContent objectWithKeyValues:dict];
             
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,[dict objectForKey:@"mSmallImageUrl"]];
             [self.allNewsArr addObject:model];
         }
         
         
         
         
         //成功以后我就进度条
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {

             [MBProgressHUD showError:@"没有更多新闻"];
         }
         

         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.footer endRefreshing];
}



#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
//    [MBProgressHUD showMessage:@"正在请求" toView:window];
//
    
    [MBProgressHUD showSuccess:@"正在加载"];


    //下拉刷新 我要把数组清空 获取最新的
    // 每一次刷新之前 我要把之前的新闻remove
    [self.allNewsArr removeAllObjects];
    // 成功了我就刷新tableview;
    [self.tableView reloadData];

    
   //加载网络数据
   // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getNewsTitle_Pre";
    params[@"news_id"] = @"0";
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功--%@", responseObject);

         //成功以后我就进度条
   //      [MBProgressHUD hideHUDForView:window animated:YES];

         
         //获得新闻数组
         NSArray *newsList = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         for (NSDictionary *dict in newsList) {
             newsContent * model =  [newsContent objectWithKeyValues:dict];

             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,[dict objectForKey:@"mSmallImageUrl"]];
             [self.allNewsArr addObject:model];
         }
         

         
         
         //成功以后我就进度条
       //  [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             [MBProgressHUD showError:str];
         }
         

         
        // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
      //   [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.header endRefreshing];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.allNewsArr.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDNewsListCell" forIndexPath:indexPath];
    
    newsContent * model = self.allNewsArr[indexPath.row];
    
    // 设置列表的图片
    UIImageView * imageView = (UIImageView * )[cell viewWithTag:21];
    NSURL *url = [NSURL URLWithString:model.mSmallImageUrl];
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default_474_334"]];
    
    // 设置标题
    UILabel *text = (UILabel *)[cell viewWithTag:22];
    text.text = model.mTitle;
    text.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:22];
    text.textColor = CustomGreenColor;
    
    // 设置来源与作者
    UILabel * scr = (UILabel *)[cell viewWithTag:23];
    scr.text = model.mSrc;
    
    // 设置创建的时间
    UILabel * time = (UILabel *) [cell viewWithTag:24];
    time.text = model.mCreateTime;
    
    // 设置选中颜色不变
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 109;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:20];
    
    [whiteView setBackgroundColor:[UIColor grayColor]];
    [UIView animateWithDuration:0.2f animations:^{
         [whiteView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDNewsDetailViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"newsDetail"];
        
        viewController.model = self.allNewsArr[indexPath.row];
        
        // viewController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:viewController animated:YES];

    }];
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [TalkingData trackPageBegin:@"新闻列表"];
    WDTabBarController * tabBar = (WDTabBarController *) self.tabBarController;
   // if(tabBar.tabBar.hidden == YES){
        tabBar.tabBar.hidden = NO;
   // }


}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [TalkingData trackPageEnd:@"新闻列表"];

}

//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [TalkingData trackPageEnd:@"新闻列表"];
//}


@end
