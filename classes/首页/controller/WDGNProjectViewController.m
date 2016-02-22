//
//  WDGNProjectViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/16.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDGNProjectViewController.h"
#import "ASProgressPopUpView.h"
#import "WDOptButtonView.h"
#import "WDTabBarController.h"
#import "WDShowProject.h"
//#import "WDShowProjectDetail.h"
//#import "WDtempJXModel.h"
//#import "WDtempWCModel.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "WDProjectModel.h"
#import "zhongchouzhongViewController.h"
#import "yurezhongViewController.h"
#import "WDInfoTool.h"
#import "TalkingData.h"


@interface WDGNProjectViewController ()<ASProgressPopUpViewDataSource,WDOptButtonViewDelegate>

@property (assign,nonatomic) BOOL selectedJingxing;
@property (assign,nonatomic) BOOL selectedYiwancheng;
@property (assign,nonatomic) BOOL selectedYurezhong;

@property (strong , nonatomic) NSMutableArray * arrJinxin;
@property (strong , nonatomic) NSMutableArray * arrYure;
@property (strong , nonatomic) NSMutableArray * arrWanc;

// 记录预热中 已经完成有没有项目；

@property (copy , nonatomic) NSString * yurezhongWarn;
@property (copy , nonatomic) NSString * yiwanchengWarn;


@end




@implementation WDGNProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.selectedJingxing = YES;
    self.selectedYurezhong = NO;
    self.selectedYiwancheng = NO;
    
    self.yurezhongWarn = @"";
    self.yiwanchengWarn = @"";
    
    // 设置标题
    if ([self.type isEqualToString:@"1"]) {    // 1就是国内 4是海外
        [self.navigationItem setTitle:@"股权投资"];
    }
    
    if ([self.type isEqualToString:@"4"]) {    // 1就是国内 4是海外
        [self.navigationItem setTitle:@"海外项目"];
    }

    
    
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






//#pragma mark 上拉加载更多数据
//- (void)loadMoreData
//{
//    //    // 1.添加假数据
//    //    for (int i = 0; i<5; i++) {
//    //        [self.data addObject:MJRandomData];
//    //    }
//    
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
    
    [self refreshJX];//进行中
    [self refreshYR];//预热中
    [self refreshWC];//完成
    
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
}



#pragma mark - 刷新列表
-(void)refreshJX{
    
   // UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getRunningProject";//getRunningProject获取进行中项目
//    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
//    params[@"user_id"] = userID;
    params[@"type"] = self.type; // 1就是国内 4是海外；
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功-refreshJX-%@", responseObject);
         
      //获得数组数组
      NSArray *list = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
      [self.arrJinxin removeAllObjects];

      for (NSDictionary *dict in list) {
        WDShowProject  * model =  [WDShowProject objectWithKeyValues:dict];
          model.mFullImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mFullImageUrl];
          model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
          
          [self.arrJinxin addObject:model];
      }
         NSLog(@"请求成功-refreshWC-%@", self.arrJinxin);
         
         //成功以后就去掉进度框
 //        [MBProgressHUD hideHUDForView:window animated:YES];
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str =@"暂无进行中项目";
             [MBProgressHUD showError:str];
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
    //     [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];

}

-(void)refreshYR{
 //   UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getPrepareProject"; //getPrepareProject获取预热中项目
//    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
//    params[@"user_id"] = userID;
    params[@"type"] = self.type; // 1就是国内 4是海外；

    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功-refreshYR-%@", responseObject);
         
         //获得数组数组
         NSArray *list = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         [self.arrYure removeAllObjects];
         
         for (NSDictionary *dict in list) {
             WDShowProject  * model =  [WDShowProject objectWithKeyValues:dict];
             model.mFullImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mFullImageUrl];
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
             
             [self.arrYure addObject:model];
         }
         NSLog(@"请求成功-refreshWC-%@", self.arrYure);

         //成功以后我就进度条
    //     [MBProgressHUD hideHUDForView:window animated:YES];
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
//             NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             //NSString * str =@"暂无预热中项目";
             self.yurezhongWarn = @"暂无预热中项目";
             //[MBProgressHUD showError:str];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
       //  [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];

}

-(void)refreshWC{
   // UIWindow * window = [[UIApplication sharedApplication].windows lastObject];

    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getFinishProject";  //getFinishProject获取已完成项目
//    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
//    params[@"user_id"] = userID;
    params[@"type"] = self.type; // 1就是国内 4是海外；
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功-refreshWC-%@", responseObject);
         
         //获得数组数组
         NSArray *list = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         [self.arrWanc removeAllObjects];
         
         for (NSDictionary *dict in list) {
             WDShowProject  * model =  [WDShowProject objectWithKeyValues:dict];
             model.mFullImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mFullImageUrl];
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
             
             [self.arrWanc addObject:model];
         }
         NSLog(@"请求成功-refreshWC-%@", self.arrWanc);

         
         //成功以后我就进度条
   //      [MBProgressHUD hideHUDForView:window animated:YES];
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
//             NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
           //  NSString * str =@"暂无已完成项目";
             self.yiwanchengWarn = @"暂无已完成项目";
             //[MBProgressHUD showError:str];
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
        // [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
 
}





#pragma mark - 进行中
-(NSMutableArray * )arrJinxin{
    if (nil == _arrJinxin) {
        _arrJinxin = [NSMutableArray array];
    }
    return _arrJinxin;
    
}

#pragma mark - 预热的
-(NSMutableArray * )arrYure{
    if (nil == _arrYure) {
        _arrYure = [NSMutableArray array];
    }
    return _arrYure;
    
}


#pragma mark - 完成了
-(NSMutableArray * )arrWanc{
    if (nil == _arrWanc) {
        _arrWanc = [NSMutableArray array];
    }
    return _arrWanc;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    if (self.selectedJingxing == YES) {
        return self.arrJinxin.count;
    }
    
    if (self.selectedYurezhong == YES) {
        return self.arrYure.count;
    }

    return self.arrWanc.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    
    if (indexPath.section == 0) {
        CGRect frame = CGRectMake(0, 0, 414, 200);
        if ([[UIScreen mainScreen] bounds].size.width > 375) {
            frame = CGRectMake(0, 0, 414, 200);;
        }else if([[UIScreen mainScreen] bounds].size.width <= 375 &&[[UIScreen mainScreen] bounds].size.width > 320){
            frame = CGRectMake(0, 0, 375, 180);
        }else{
            frame = CGRectMake(0, 0, 320, 130);
        }
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
        [imageView setImage:[UIImage imageNamed:@"guquantouzi"]];
        
        if ([self.type isEqualToString:@"4"]) {    // 1就是国内 4是海外
            [imageView setImage:[UIImage imageNamed:@"haiwaizhuanti"]];
        }

        
        
       // [cell.contentView setBackgroundColor:[UIColor redColor]];
        [cell addSubview:imageView];
    }
    
    if (indexPath.section == 1) {
        // 加载正在进行中；
        if (self.selectedJingxing == YES) {
            
            if (self.arrJinxin.count == 0) {return nil;}
            
            WDShowProject * model = self.arrJinxin[indexPath.row];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"WDGNProjectJXCell" forIndexPath:indexPath];
            ASProgressPopUpView * progressPopUpView = (ASProgressPopUpView *)[cell viewWithTag:24];
            [progressPopUpView showPopUpViewAnimated:YES];
            progressPopUpView.popUpViewCornerRadius = 8.0;
            progressPopUpView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
            progressPopUpView.dataSource = self;
            
            // 图片
            UIImageView * image = [cell viewWithTag:21];
            [image sd_setImageWithURL:[NSURL URLWithString:model.mSmallImageUrl] placeholderImage:[UIImage imageNamed:@"default_240_324"]];

           // 进度条进度；
            CGFloat scale =[model.mCurMoney floatValue]/[model.mGoalMoney floatValue];
            int scalePer = scale * 100;
            NSString * str1 = [NSString stringWithFormat:@"%d",scalePer];
            scale = [str1 floatValue] / 100.0;
            NSString * str= [NSString stringWithFormat:@"%d%%",scalePer];
            
            // 进度条
            [UIView animateWithDuration:0.25f animations:^{
            [progressPopUpView setProgress:scale animated:YES];}];
            
            // 完成率
            UILabel * wanchenglv = [cell viewWithTag:27];
            [wanchenglv setText:str];

            // title
            UILabel * name  =[cell viewWithTag:22];
            [name setText:model.mTitle];
            if([UIScreen mainScreen].applicationFrame.size.width < 375){   // 6
                [name setFont:[UIFont systemFontOfSize:14.0f]];
            }else{
                [name setFont:[UIFont systemFontOfSize:17.0f]];
            }

            
            
            // 项目简介
            UILabel * jianjie  =[cell viewWithTag:23];
            [jianjie setText:model.mDestrible];
            
            // 目标金额
            UILabel * mubiaojine = [cell viewWithTag:25];
            NSString * tempmGoalMoney =[[NSString alloc] init];
            tempmGoalMoney = [NSString stringWithFormat:@"￥%@万",model.mGoalMoney];
            [mubiaojine setText:tempmGoalMoney];
            
            // 已众筹
            UILabel * yirenchou = [cell viewWithTag:26];
            NSString * tempmCurMoney = [[NSString alloc] init];
            tempmCurMoney = [NSString stringWithFormat:@"￥%@万",model.mCurMoney];
            [yirenchou setText:tempmCurMoney];

//
        }
        // 加载预热中；
        if (self.selectedYurezhong == YES) {
            
            if (self.arrYure.count == 0) {return nil;}

            //WDtempWCModel * mode = self.arrYure[indexPath.row];
            WDShowProject * model = self.arrYure[indexPath.row];

            
            cell = [tableView dequeueReusableCellWithIdentifier:@"WDGNProjectYRCell" forIndexPath:indexPath];
            ASProgressPopUpView * progressPopUpView = (ASProgressPopUpView *)[cell viewWithTag:24];
            [progressPopUpView showPopUpViewAnimated:YES];
            progressPopUpView.popUpViewCornerRadius = 8.0;
            progressPopUpView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
            progressPopUpView.progress = 0.0;
            progressPopUpView.dataSource = self;
            
            progressPopUpView.popUpViewColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:0.8f];
            
            // 图片
            UIImageView * image = [cell viewWithTag:21];
            [image sd_setImageWithURL:[NSURL URLWithString:model.mSmallImageUrl] placeholderImage:[UIImage imageNamed:@"default_240_324"]];
            
            // title
            UILabel * name  =[cell viewWithTag:22];
            [name setText:model.mTitle];
            if([UIScreen mainScreen].applicationFrame.size.width < 375){   // 6
                [name setFont:[UIFont systemFontOfSize:14.0f]];
            }else{
                [name setFont:[UIFont systemFontOfSize:17.0f]];
            }


            //简介
            UILabel * jianjie  =[cell viewWithTag:23];
            [jianjie setText:model.mDestrible];
            
            // 目标金额
            UILabel * mubiaojine = [cell viewWithTag:25];
            NSString * tempmGoalMoney =[[NSString alloc] init];
            tempmGoalMoney = [NSString stringWithFormat:@"￥%@万",model.mGoalMoney];
            [mubiaojine setText:tempmGoalMoney];
            
            
            // 已众筹
            UILabel * yirenchou = [cell viewWithTag:26];
            NSString * tempmCurMoney = [[NSString alloc] init];
            tempmCurMoney = [NSString stringWithFormat:@"￥%@万",model.mCurMoney];
            [yirenchou setText:tempmCurMoney];
        
        }
        
        
        // 加载已完成；
        if (self.selectedYiwancheng == YES) {
            
            if (self.arrWanc.count == 0) {return nil;}

            WDShowProject * model = self.arrWanc[indexPath.row];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"WDGNProjectJXCell" forIndexPath:indexPath];
            ASProgressPopUpView * progressPopUpView = (ASProgressPopUpView *)[cell viewWithTag:24];
            [progressPopUpView showPopUpViewAnimated:YES];
            progressPopUpView.popUpViewCornerRadius = 8.0;
            progressPopUpView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
            progressPopUpView.progress = 1.0;
            progressPopUpView.dataSource = self;
            
            // 图片
            UIImageView * image = [cell viewWithTag:21];
            [image sd_setImageWithURL:[NSURL URLWithString:model.mSmallImageUrl] placeholderImage:[UIImage imageNamed:@"default_240_324"]];
            
            // 进度条进度；
            CGFloat scale =[model.mCurMoney floatValue]/[model.mGoalMoney floatValue];
            int scalePer = scale * 100;
            NSString * str1 = [NSString stringWithFormat:@"%d",scalePer];
            scale = [str1 floatValue] / 100.0;
            NSString * str= [NSString stringWithFormat:@"%d%%",scalePer];
            
            // 进度条
            [UIView animateWithDuration:0.25f animations:^{
                [progressPopUpView setProgress:scale animated:YES];}];
            
            // 完成率
            UILabel * wanchenglv = [cell viewWithTag:27];
            [wanchenglv setText:str];
            
            // title
            UILabel * name  =[cell viewWithTag:22];
            [name setText:model.mTitle];
            if([UIScreen mainScreen].applicationFrame.size.width < 375){   // 6
                [name setFont:[UIFont systemFontOfSize:14.0f]];
            }else{
                [name setFont:[UIFont systemFontOfSize:17.0f]];
            }

            
            // 项目简介
            UILabel * jianjie  =[cell viewWithTag:23];
            [jianjie setText:model.mDestrible];
            
            // 目标金额
            UILabel * mubiaojine = [cell viewWithTag:25];
            NSString * tempmGoalMoney =[[NSString alloc] init];
            tempmGoalMoney = [NSString stringWithFormat:@"￥%@万",model.mGoalMoney];
            [mubiaojine setText:tempmGoalMoney];
            
            // 已众筹
            UILabel * yirenchou = [cell viewWithTag:26];
            NSString * tempmCurMoney = [[NSString alloc] init];
            tempmCurMoney = [NSString stringWithFormat:@"￥%@万",model.mCurMoney];
            [yirenchou setText:tempmCurMoney];
        }
 
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGRect frame = CGRectMake(0, 0, 414, 200);
        if ([[UIScreen mainScreen] bounds].size.width > 375) {
            frame = CGRectMake(0, 0, 414, 200);;
        }else if([[UIScreen mainScreen] bounds].size.width <= 375 &&[[UIScreen mainScreen] bounds].size.width > 320){
            frame = CGRectMake(0, 0, 375, 180);
        }else{
            frame = CGRectMake(0, 0, 320, 130);
        }

        return frame.size.height;
    }
    
    return 250;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        WDOptButtonView * optView = [[[NSBundle mainBundle] loadNibNamed:@"WDOptButtonView" owner:nil options:nil] lastObject];
        if (self.selectedJingxing == YES) {
//            [optView.jinxingzhong setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [optView.yurezhong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [optView.yiwancheng setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            UIImageView * imageview = (UIImageView *)[optView viewWithTag:20];
            [imageview setImage:[UIImage imageNamed:@"WDOptButton1"]];
        }
        if (self.selectedYurezhong == YES) {
//            [optView.yurezhong setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [optView.jinxingzhong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [optView.yiwancheng setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            UIImageView * imageview = (UIImageView *)[optView viewWithTag:20];
            [imageview setImage:[UIImage imageNamed:@"WDOptButton2"]];
        }
        if (self.selectedYiwancheng == YES) {
//            [optView.yiwancheng setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [optView.yurezhong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [optView.jinxingzhong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            UIImageView * imageview = (UIImageView *)[optView viewWithTag:20];
            [imageview setImage:[UIImage imageNamed:@"WDOptButton3"]];
        }

        
        optView.delegate = self;
        return optView;
    }
    
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 50;
    }
    return 0;
}




// 精度条
- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress{
    
    return nil;
    
}


#pragma mark - 选项卡的代理方法；
-(void)optSelectedjinxingzhong{
   // NSLog(@"optSelectedjinxingzhong");
    if (self.selectedJingxing == NO) {
        self.selectedJingxing = YES;
        self.selectedYurezhong = NO;
        self.selectedYiwancheng = NO;
        NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

        
    }
    
    
    
    
}
-(void)optSelectedyurezhong{
    
    if (![self.yurezhongWarn isEqualToString:@""]) {
        [MBProgressHUD showError:self.yurezhongWarn];
        self.yurezhongWarn = @"";
    }
    
    if (self.selectedYurezhong == NO) {
        self.selectedYurezhong = YES;
        self.selectedJingxing = NO;
        self.selectedYiwancheng = NO;
        NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

    }}

-(void)optSelectedyiwancheng{
    if (![self.yiwanchengWarn isEqualToString:@""]) {
        [MBProgressHUD showError:self.yiwanchengWarn];
        self.yiwanchengWarn = @"";

    }

    if (self.selectedYiwancheng == NO) {
        self.selectedYiwancheng = YES;
        self.selectedJingxing = NO;
        self.selectedYurezhong = NO;
        NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
 
    }
}




#pragma mark -UITableviewCellsourceDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

    
    
    
    if (indexPath.section == 1) {
        if (self.selectedJingxing == YES) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            zhongchouzhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDjingxingzhongViewController"];
            controller.model = self.arrJinxin[indexPath.row];
            controller.type = @"jxz";
            controller.userID = userID;
            [self.navigationController pushViewController:controller animated:YES];
        }
        if (self.selectedYurezhong == YES) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            yurezhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDyurezhongViewController"];
            controller.model = self.arrYure[indexPath.row];
            controller.userID = userID;
            [self.navigationController pushViewController:controller animated:YES];
        }
        if (self.selectedYiwancheng == YES) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            zhongchouzhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDjingxingzhongViewController"];
            controller.model = self.arrWanc[indexPath.row];
            controller.type = @"ywc";
            controller.userID = userID;
            [self.navigationController pushViewController:controller animated:YES];
        }

    }
    

}

-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    tab.tabBar.hidden = YES;
    
    [TalkingData trackPageBegin:@"股权众筹"];

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageEnd:@"股权众筹"];
}


@end
