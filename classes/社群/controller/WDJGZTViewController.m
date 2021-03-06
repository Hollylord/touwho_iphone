//
//  WDJGZTViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/18.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDJGZTViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载


#import "WDOrgListModel.h" // 机构列表
#import "WDJGZTDetailViewController.h" //机构专题详情页面
#import "WDInfoTool.h"  // 获取userid



@interface WDJGZTViewController ()

//存放下拉的所有机构模型
@property (strong, nonatomic) NSMutableArray *allOrgArr;


@end

@implementation WDJGZTViewController

#pragma mark - 懒加载 加载机构的总数量；
- (NSMutableArray *)allOrgArr{
    if (!_allOrgArr) {
        _allOrgArr = [NSMutableArray array];
    }
    return _allOrgArr;
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
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:window];
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getOrganizations";
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功--%@", responseObject);
         //成功以后我就进度条
         [MBProgressHUD hideHUDForView:window animated:YES];
         
         // 先清空
         [self.allOrgArr removeAllObjects];
         
        NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         for (NSDictionary * dict in arry) {
             WDOrgListModel * model = [WDOrgListModel objectWithKeyValues:dict];
             model.mLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mLogo];
             [self.allOrgArr addObject:model];
         }
         
         //成功
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
             NSString * str = @"加载成功";
             [MBProgressHUD showSuccess:str];
             
         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"没有数据";
             [MBProgressHUD showError:str];
         }
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
    //        [self.tableView reloadData];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allOrgArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDJGZTcell" forIndexPath:indexPath];

    // 取出模型
    WDOrgListModel * model =self.allOrgArr[indexPath.row];
    
    // 设置白色的背景
    UIView * whiteView = [cell viewWithTag:20];
    whiteView.layer.masksToBounds = YES;
    whiteView.layer.cornerRadius = 3.0f;
    whiteView.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
    whiteView.layer.borderWidth = 1.0f;

    // 设置图片
    UIImageView * image = [cell viewWithTag:21];
    [image sd_setImageWithURL:[NSURL URLWithString:model.mLogo] placeholderImage:[UIImage imageNamed:@"default_194_132"]];
    
    //titile
    UILabel * title = [cell viewWithTag:22];
    [title setText:model.mShortName];
    
    //创建时间
    UILabel * time = [cell viewWithTag:23];
    [time setText:model.mCreateTime];
    
    //机构全称
    UITextView * destrible = [cell viewWithTag:24];
    [destrible setText:model.mDestrible];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([[UIScreen mainScreen] bounds].size.width > 375) {
        return 180;    }
    
    if([[UIScreen mainScreen] bounds].size.width <= 375 &&[[UIScreen mainScreen] bounds].size.width > 320){
        return 150;
    }

    return 120;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 120)];
    
    if ([[UIScreen mainScreen] bounds].size.width > 375) {
        image.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 180);
    }else if([[UIScreen mainScreen] bounds].size.width <= 375 &&[[UIScreen mainScreen] bounds].size.width > 320){
       image.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 150);
    }else{
        image.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 120);
    }

    [image setImage:[UIImage imageNamed:@"touzishequ"]];
    return image;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:20];
    [whiteView setBackgroundColor:[UIColor grayColor]];
    [UIView animateWithDuration:0.2f animations:^{
        [whiteView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDJGZTDetailViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDJGZTDetail"];
        controller.hidesBottomBarWhenPushed = YES;
        controller.orgModel = self.allOrgArr[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    }];
    
}


@end
