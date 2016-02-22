//
//  WDVideoTableViewController.m
//  ZBT
//
//  Created by 投壶 on 15/10/13.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDVideoTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import "WDActivityListModel.h"
#import "WDActivityDetailModel.h"
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载
#import "WDActivityDetalController.h"
#import "WDVideoModel.h"
#import "WDVideoListBtn.h"  //按钮-加多了几个标记

#import "UMSocial.h"
#import "TalkingData.h" // talkdata
//#import "WDVideoNavigationViewController.h" // 视频播放页面的导航
//#import "WDVideoViewController.h"
#import "UIVideoDiscoverViewController.h" // 蒙版


@interface WDVideoTableViewController () <UMSocialUIDelegate>
//存放下拉的所有活动模型
@property (strong, nonatomic) NSMutableArray *allVideoArr;
@property (nonatomic ,weak) UIVideoDiscoverViewController *vc;


@end

@implementation WDVideoTableViewController


#pragma mark - 懒加载 加载视频的总数量；
- (NSMutableArray *)allVideoArr{
    if (!_allVideoArr) {
        _allVideoArr = [NSMutableArray array];
    }
    return _allVideoArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 去掉分割线；
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
    

   //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillExitFullscreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillShowFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
    

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
    params[@"method"] = @"getInformationVideo";
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功--%@", responseObject);
         //成功以后我就进度条
     //    [MBProgressHUD hideHUDForView:window animated:YES];
         
         // 先清空
        [self.allVideoArr removeAllObjects];
         
         NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         for (NSDictionary * dict in arry) {
             WDVideoModel * model = [WDVideoModel objectWithKeyValues:dict];
             [self.allVideoArr addObject:model];
         }
         
//         //成功
//         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
//             NSString * str = @"加载成功";
//             [MBProgressHUD showSuccess:str];
//             
//         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"暂无视频数据";
             [MBProgressHUD showError:str];
         }
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
    //     [MBProgressHUD hideHUDForView:window animated:YES];
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
    return self.allVideoArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoListCell" forIndexPath:indexPath];
    
    WDVideoModel * model = self.allVideoArr[indexPath.row];
    
//    // 播放按钮
//    WDVideoListBtn * btn = (WDVideoListBtn *)[cell viewWithTag:23];
//    btn.videoListBtnMark = indexPath.row; // 加上了一百
//    btn.layer.masksToBounds = YES;
//    btn.layer.cornerRadius = 3.0f;
//    btn.layer.borderWidth = 1.0f;
//    btn.layer.borderColor =(__bridge CGColorRef)([UIColor blackColor]);
//    [btn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    // 白色的背景
    UIView * whiteView = [cell viewWithTag:20];
    whiteView.layer.masksToBounds = YES;
    whiteView.layer.cornerRadius = 3.0f;
    whiteView.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
    whiteView.layer.borderWidth = 1.0f;

    
//    // 视频图片
//    UIImageView * image = (UIImageView *)[cell viewWithTag:21];
//    image.layer.masksToBounds = YES;
//    image.layer.cornerRadius = 5.0f;
//    image.layer.borderWidth = 1.0f;
//    image.layer.borderColor =(__bridge CGColorRef)([UIColor blackColor]);
//    

    //视频
    UIWebView * webView = [cell viewWithTag:21];
    NSURL * url =[NSURL URLWithString:model.mVideoUrl];
   // NSURL * url =[NSURL URLWithString:@"http://player.youku.com/embed/XMTM3NDI2NDM3Mg=="];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    webView.scalesPageToFit = YES;
   // webView.contentScaleFactor = NO;
    UIScrollView *tempView=(UIScrollView *)[webView.subviews objectAtIndex:0];
    tempView.scrollEnabled=NO;


    
    // 视频名字
    UILabel * videoTitle = [cell viewWithTag:22];
    [videoTitle setText:model.mName];
    
    // 分享按钮
    
    WDVideoListBtn * shardBtn = [cell viewWithTag:25];
    shardBtn.videoListBtnMark = indexPath.row; // 加上了一百
    [shardBtn addTarget:self action:@selector(shared:) forControlEvents:UIControlEventTouchUpInside];

    // 去掉点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//-(void)play:(WDVideoListBtn *)btn{
//    WDVideoModel * model = self.allVideoArr[btn.videoListBtnMark];
//    
////    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
////    UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"speechView"];
////    //[self.navigationController pushViewController:controller animated:YES];
////    [self presentViewController:controller animated:YES completion:nil];
//    
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    WDVideoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDVideoViewController"];
//    NSLog(@"---------shipingdizhi--%@", model.mVideoUrl);
//    controller.videoUrl = model.mVideoUrl;
//    //[self presentViewController:controller animated:YES completion:nil];
//    [self.navigationController pushViewController:controller animated:YES];
//}


#pragma mark - 友盟分享
-(void)shared:(WDVideoListBtn*)btn{
    WDVideoModel * model = self.allVideoArr[btn.videoListBtnMark];
    NSString * str = [NSString stringWithFormat:@"%@\n%@\n",model.mName,model.mVideoUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:str
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([UIScreen mainScreen].applicationFrame.size.width == 414 ){  // 6p
       return 270;
    }
    if([UIScreen mainScreen].applicationFrame.size.width == 375){   // 6
      return 250;
    }
    return 220;
}


- (BOOL)shouldAutorotate
{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [TalkingData trackPageBegin:@"视频页面"];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageEnd:@"视频页面"];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeVisibleNotification object:nil];
}

-(void)playerWillExitFullscreen{
    if([[UIDevice currentDevice].systemVersion doubleValue] < 9.0){
        NSLog(@"退出播放视频了");
        /**
         下边方法的使用场景:
         如果点击视频,自动旋转为横屏播放状态,点击完成按钮,需要是程序变为竖屏状态,需要下边的代码
         */
        //        UIViewController *vc = [[UIViewController alloc] init];
        //        //[vc.view setBackgroundColor:[UIColor whiteColor]];
        //        //self.vc = vc;
        //        [self presentViewController:vc animated:NO completion:nil];
        //
        [self.vc dismissViewControllerAnimated:NO completion:nil];
        
    }
    
}

-(void)playerWillShowFullScreen{
    if([[UIDevice currentDevice].systemVersion doubleValue] < 9.0){
        NSLog(@"播放视频了");
        UIVideoDiscoverViewController *vc = [[UIVideoDiscoverViewController alloc] init];
        
        
        
        
        
        //[vc.view setBackgroundColor:[UIColor whiteColor]];
        self.vc = vc;
        [self presentViewController:vc animated:NO completion:nil];
    }
    
}

@end
