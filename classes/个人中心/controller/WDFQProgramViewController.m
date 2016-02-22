//
//  WDFQProgramViewController.m
//  ZBT
//
//  Created by 投壶 on 15/10/10.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDFQProgramViewController.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "WDProjectModel.h"

#import "WDShowProject.h"

#import "zhongchouzhongViewController.h"




@interface WDFQProgramViewController ()

//存放下拉的所有项目模型
@property (strong, nonatomic) NSMutableArray *allArr;


@end

@implementation WDFQProgramViewController


#pragma mark - 懒加载 总数量；
- (NSMutableArray *)allArr{
    if (!_allArr) {
        _allArr = [NSMutableArray array];
    }
    return _allArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
//    // 下拉刷新
//    
//    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
//    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [weakSelf loadMoreData];
//    }];
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];

    
}





#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    //    // 1.添加假数据
    //    for (int i = 0; i<5; i++) {
    //        [self.data addObject:MJRandomData];
    //    }
    
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
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 声明：不要对服务器返回的数据进行解析，直接返回data即可
    // 如果是文件下载，肯定是用这个
    // responseObject的类型是NSData
    // mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
    
    //    // 1.添加假数据
    //    for (int i = 0; i<5; i++) {
    //        [self.data insertObject:MJRandomData atIndex:0];
    //    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 刷新表格
    
    
    //设置进度条；
//[MBProgressHUD showMessage:@"正在加载" toView:self.view];
    
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"myBuildProject";
    params[@"user_id"] = self.mID;
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功--%@", responseObject);
         
         //获得数组数组
         NSArray *jsonArr = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];

        [self.allArr removeAllObjects];
         
         for (NSDictionary *dict in jsonArr) {
             WDShowProject * model =  [WDShowProject objectWithKeyValues:dict];
             
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,[dict objectForKey:@"mSmallImageUrl"]];
             [self.allArr addObject:model];
         }
         
         
         
         //成功以后我就进度条
       //  [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             [MBProgressHUD showError:str];
         }

         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"xiangmu" forIndexPath:indexPath];
    WDShowProject * model = self.allArr[indexPath.row];
    
    // 头像
    UIImageView * image = [cell viewWithTag:21];
    [image sd_setImageWithURL:[NSURL URLWithString:model.mSmallImageUrl] placeholderImage:[UIImage imageNamed:@"default_120"]];
    
    //名字
    UITextView * textView = [cell viewWithTag:24];
    [textView setText:model.mTitle];
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    NSLog(@"--- indexrow-%ld",(long)indexPath.row);
    
    
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * whiteView = [cell viewWithTag:20];
    [UIView animateWithDuration:0.1f animations:^{
        [whiteView setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0f]];
    } completion:^(BOOL finished) {
        [whiteView setBackgroundColor:[UIColor whiteColor]];
                         
     UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     zhongchouzhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDjingxingzhongViewController"];
     WDShowProject * model = self.allArr[indexPath.row];
     NSString * type = [[NSString alloc] init];
     if ([model.mType isEqualToString:@"3"]||[model.mType isEqualToString:@"4"]) {
         type = @"ywc";
     }else{
         type = @"jxz";
     }
     controller.model = model;
     controller.type = type;
     controller.userID = self.mID;
     [self.navigationController pushViewController:controller animated:YES];

                     }];
}

@end
