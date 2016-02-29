//
//  WDActivityListViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/10.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDActivityListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import "WDActivityListModel.h"
#import "WDActivityDetailModel.h"
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载
#import "WDActivityDetalController.h"


#import "UMSocial.h"


@interface WDActivityListViewController ()
//存放下拉的所有活动模型
@property (strong, nonatomic) NSMutableArray *allActivityArr;


@end

@implementation WDActivityListViewController

#pragma mark - 懒加载 加载新闻的总数量；
- (NSMutableArray *)allActivityArr{
    if (!_allActivityArr) {
        _allActivityArr = [NSMutableArray array];
    }
    return _allActivityArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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


//
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



#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
//    [MBProgressHUD showMessage:@"正在加载" toView:window];
//    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getActivity";
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功--%@", responseObject);
         //成功以后我就进度条
       //  [MBProgressHUD hideHUDForView:window animated:YES];
         
         // 先清空
         [self.allActivityArr removeAllObjects];
         
         NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         for (NSDictionary * dict in arry) {
             WDActivityListModel * model = [WDActivityListModel objectWithKeyValues:dict];
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
             [self.allActivityArr addObject:model];
         }
         
         
//         //成功
//         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
//             NSString * str = @"加载成功";
//             [MBProgressHUD showSuccess:str];
//             
//         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"加载失败";
             [MBProgressHUD showError:str];
         }
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
      //   [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
    //        [self.tableView reloadData];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
    // });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allActivityArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDActivityCell" forIndexPath:indexPath];
    
    WDActivityListModel * model = self.allActivityArr[indexPath.row];
    
    // 状态按钮
    UIImageView * tag = (UIImageView *)[cell viewWithTag:23];
    
    
    UIView * whiteView = [cell viewWithTag:21];
    whiteView.layer.masksToBounds = YES;
    whiteView.layer.cornerRadius = 3.0f;
    whiteView.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
    whiteView.layer.borderWidth = 1.0f;

    if ([model.mStatus isEqualToString:@"0"]) { //活动状态   进行中是1  未开始0  已经结束是2
        [tag setImage:[UIImage imageNamed:@"tagPre"]];
    }
    
    if ([model.mStatus isEqualToString:@"1"]) { //活动状态   进行中是1  未开始0  已经结束是2
        [tag setImage:[UIImage imageNamed:@"tagOn"]];
    }
    
    if ([model.mStatus isEqualToString:@"2"]) { //活动状态   进行中是1  未开始0  已经结束是2
        [tag setImage:[UIImage imageNamed:@"tagEnd"]];
    }

    
    
    // 图片
    UIImageView * image = [cell viewWithTag:22];
    [image sd_setImageWithURL:[NSURL URLWithString:model.mSmallImageUrl] placeholderImage:[UIImage imageNamed:@"default_474_334"]];
    
    //titile
    UILabel * title = [cell viewWithTag:24];
    [title setText:model.mTitle];
    if([UIScreen mainScreen].applicationFrame.size.width < 375){   // 6
        [title setFont:[UIFont systemFontOfSize:14.0f]];
    }else{
        [title setFont:[UIFont systemFontOfSize:16.0f]];
    }

    
    //time
    UILabel * time = [cell viewWithTag:25];
    [time setText:model.mTime];
    
    //address
    UITextView * address = [cell viewWithTag:26];
    [address setText:model.mAddress];

    // 去掉点击后的颜色；
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:21];
    
    
    [whiteView setBackgroundColor:[UIColor grayColor]];
    [UIView animateWithDuration:0.25f animations:^{
        [whiteView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDActivityDetalController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDActivityDetalController"];
        controller.model = self.allActivityArr[indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
    }];

    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}



@end
