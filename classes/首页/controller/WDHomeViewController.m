//
//  WDHomeViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/15.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDHomeViewController.h"
#import "WDNewsCell.h"
#import "WDnews.h"
#import "WDTabBarController.h"

#import  <MJExtension.h> // 字典转模型
#import "UIView+Extension.h"
#import "ASProgressPopUpView.h"
#import "WDOptButtonView.h"
#import "WDTabBarController.h"
#import "WDShowProject.h"
//#import "WDShowProjectDetail.h"
//#import "WDtempJXModel.h"
//#import "WDtempWCModel.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "WDProjectModel.h"
#import "zhongchouzhongViewController.h"
#import "yurezhongViewController.h"
#import "WDInfoTool.h"
#import "TalkingData.h"




//#import "newHomeBtn.h"  // 首页的按钮
//#import "newHomeBtn2.h"  // 首页的按钮



#define kMaxSections 10
#define images 4

typedef enum {
    ToLetf,
    ToRight
}direction ;

@interface WDHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate,ASProgressPopUpViewDataSource,WDOptButtonViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *WDpageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *WDCollection;
@property (nonatomic, strong) NSMutableArray *newses;
@property(strong ,nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UIButton *guquanButton;
@property (weak, nonatomic) IBOutlet UIButton *haiwaiButton;


@property (weak, nonatomic) IBOutlet UIView *collectionSuperView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionSuperViewHeihgt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WDPageHeight;

//- (IBAction)homeGNXM:(newHomeBtn *)sender;
//- (IBAction)homeHWXM:(newHomeBtn2 *)sender;
//- (IBAction)homeSPZC:(UIButton *)sender;
//- (IBAction)homeGYZC:(UIButton *)sender;


//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnConstranit;
//@property (weak, nonatomic) IBOutlet UIButton *constranitBtn;
@property (assign,nonatomic) BOOL selectedJingxing;
@property (assign,nonatomic) BOOL selectedYiwancheng;
@property (assign,nonatomic) BOOL selectedYurezhong;

@property (strong , nonatomic) NSMutableArray * arrJinxin;
@property (strong , nonatomic) NSMutableArray * arrYure;
@property (strong , nonatomic) NSMutableArray * arrWanc;
@property (strong , nonatomic) NSMutableArray * arrAll;

// 记录预热中 已经完成有没有项目；

@property (copy , nonatomic) NSString * yurezhongWarn;
@property (copy , nonatomic) NSString * yiwanchengWarn;


@end

@implementation WDHomeViewController
{
    CALayer *boxLayer;
    //分类按钮下划线的初始x位置
    CGFloat originalX;
    NSUInteger countsOfYurezhong;
    NSUInteger countsOfJinxingzhong;
    NSUInteger countsOfWancheng;
    
}
#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    if (tab.tabBar.hidden == YES) {
        tab.tabBar.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置尺寸 轮播图尺寸
    [self settingCollectionSize];

    // 记载轮播图内容
    [self settingCollection];
    
//    // 适配4;
//    if ([UIScreen mainScreen].applicationFrame.size.height<548) {
//        NSLog(@"4s");
//        self.btnConstranit.constant = 60;
//        [self.constranitBtn layoutIfNeeded];
//    
//    }
//    
//    // 适配5;
//    if ([UIScreen mainScreen].applicationFrame.size.height == 548) {
//        NSLog(@"5");
//        self.btnConstranit.constant = 90;
//        [self.constranitBtn layoutIfNeeded];
//        
//    }
//    
//    // 适配6;
//    if ([UIScreen mainScreen].applicationFrame.size.height == 647) {
//        NSLog(@"6");
//        self.btnConstranit.constant = 100;
//        [self.constranitBtn layoutIfNeeded];
//        
//    }
    
    self.WDpageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.WDpageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:5 green:140 blue:108 alpha:1];

    
    
    
    
    UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect titleBtnframe = CGRectMake(0, 0, 60, 27);
    titleBtn.frame = titleBtnframe;
    titleBtn.userInteractionEnabled = NO;
    [titleBtn setBackgroundImage:[UIImage imageNamed:@"homeLogo"] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleBtn;
    
    //注册项目cell
    UINib *WDGNProjectJXCell = [UINib nibWithNibName:@"WDGNProjectJXCell" bundle:nil];
    UINib *WDGNProjectYRCell = [UINib nibWithNibName:@"WDGNProjectYRCell" bundle:nil];
    [self.tableView registerNib:WDGNProjectJXCell forCellReuseIdentifier:@"WDGNProjectJXCell"];
    [self.tableView registerNib:WDGNProjectYRCell forCellReuseIdentifier:@"WDGNProjectYRCell"];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.selectedJingxing = YES;
    self.selectedYurezhong = NO;
    self.selectedYiwancheng = NO;
    
    self.yurezhongWarn = @"";
    self.yiwanchengWarn = @"";
    
    // 设置默认的type为股权投资
    self.guquanButton.selected = YES;
    self.haiwaiButton.selected = NO;
    self.type = @"1";
    
    boxLayer = [CALayer layer];
    boxLayer.bounds=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
    boxLayer.position=CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 50);
    boxLayer.delegate = self;
    [self.selectView.layer addSublayer:boxLayer];
    [boxLayer setNeedsDisplay];
    
    
    
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

-(void)settingCollectionSize{
    if ([[UIScreen mainScreen] bounds].size.width > 375) {
        self.WDPageHeight.constant = 140;
        [self.WDpageControl layoutIfNeeded];
        
        self.collectionSuperViewHeihgt.constant = 180;
        [self.collectionSuperView layoutIfNeeded];
        
    }else if([[UIScreen mainScreen] bounds].size.width <= 375 &&[[UIScreen mainScreen] bounds].size.width > 320){
        self.WDPageHeight.constant = 140;
        [self.WDpageControl layoutIfNeeded];  //180 默认
        self.collectionSuperViewHeihgt.constant = 180;
        [self.collectionSuperView layoutIfNeeded];
//
    }else{
        self.collectionSuperViewHeihgt.constant = 130;
        [self.collectionSuperView layoutIfNeeded];
        
        self.WDPageHeight.constant = 100;
        [self.WDpageControl layoutIfNeeded];
    }

}

-(void)settingCollection{
    
    
    // 注册cell
    [self.WDCollection registerNib:[UINib nibWithNibName:@"WDNewsCell" bundle:nil] forCellWithReuseIdentifier:@"news"];
    
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getBanner";

    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
        NSLog(@"请求成功setCollectionsetCollectionsetCollection---%@", responseObject);
         
         NSArray * jsonArr = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         for (NSDictionary * dict in jsonArr) {
             WDnews * model = [WDnews objectWithKeyValues:dict];
             NSString * str = model.mImageUrl;
             model.mImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,str];
             [self.newses addObject:model];
         }

         
         [self.WDCollection reloadData];
         self.WDpageControl.numberOfPages = self.newses.count;
         // 默认到中间那组
         [self.WDCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kMaxSections/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

         // 请求成功了以后才开始定时
         [self addTimer];

         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         
     }];
    

}




- (NSMutableArray *)newses{
    if (!_newses) {
        _newses = [NSMutableArray array];
    }
    return _newses;
}

#pragma mark - 定时器
// 添加定时器
-(void)addTimer{
    //定时器；
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    // 告诉主线程 在做事情的时候 分一点空间给他；
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; //我们主线程在处理一些事件 也会处理这个；
    self.timer = timer;
}




// 移除定时器；
-(void)removeTimer{
    
    [self.timer invalidate]; // 停止定时器
     self.timer = nil;
}


-(void)nextPage{
    
    if (self.timer == nil) return;
    
    
    //  就马上显示最中间那组的数据
    NSIndexPath * currentIndexPathReset=[self currentIndexPathReset];
    
    
    NSInteger nextItem = currentIndexPathReset.item + 1;
    NSInteger nextSection = currentIndexPathReset.section;
    if (nextItem == self.newses.count) {
        nextItem = 0;
        nextSection = currentIndexPathReset.section +1;
    }
    
    NSIndexPath * nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    
    [self.WDCollection scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
}

#pragma mark -显示回最中间那组；
-(NSIndexPath * )currentIndexPathReset{
    NSIndexPath * currentIndexPath = [[self.WDCollection indexPathsForVisibleItems]lastObject];
    
    //  就马上显示最中间那组的数据
    NSIndexPath * currentIndexPathReset= [NSIndexPath indexPathForItem:currentIndexPath.item inSection:kMaxSections/2];
    [self.WDCollection scrollToItemAtIndexPath:currentIndexPathReset atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    return currentIndexPathReset;
}


#pragma mark -UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.newses.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kMaxSections;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID=@"news";
    WDNewsCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
   cell.news = self.newses[indexPath.item];
    
    
    return cell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIScreen mainScreen] bounds].size.width > 375) {

        return CGSizeMake(self.view.width, 200);
    }else if([[UIScreen mainScreen] bounds].size.width <= 375 &&[[UIScreen mainScreen] bounds].size.width > 320){
        return CGSizeMake(self.view.width, 200);
    }else{
        return CGSizeMake(self.view.width, 150);
    }
    
    
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark -UICollectionViewDelegate
/**
 *  当用户开始拖拽的时候
 *
 *Dragging 拖拽 */
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
    
    
    [self.timer invalidate]; // 停止定时器
    self.timer = nil;

}
// 停止拖拽
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int page;
    if (self.newses.count == 0) {
        page = 0;
    }else{
        // 显示进度页码
    page = (int)(self.WDCollection.contentOffset.x / self.WDCollection.bounds.size.width + 0.5) % self.newses.count;
    }

    self.WDpageControl.currentPage = page;
}



/**
 *  让设备不能旋转；
 *
 *  @return <#return value description#>
 */

- (BOOL)shouldAutorotate
{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}




#pragma mark - 首页分类按钮
/**
 *  国内项目
 *
 *  
 */
//- (IBAction)homeGNXM:(newHomeBtn *)sender {
//    
////    
////    CGRect newFrame = [sender convertRect:sender.bounds fromView:sender.superview];
////    NSLog(@"newFrame - frame-x-%f--frame-y-%f",newFrame.origin.x,newFrame.origin.y);
////
////    if (newFrame.origin.x < 0) {
////        newFrame.origin.x = -newFrame.origin.x;
////    }
////    if (newFrame.origin.y < 0) {
////        newFrame.origin.y = -newFrame.origin.y;
////    }
////    
////    UIImageView * imageView = [[UIImageView alloc] init];
////    [imageView setFrame:CGRectMake(newFrame.origin.x, newFrame.origin.y, sender.width, sender.height)];
////    
////    NSLog(@"imageView - frame--%@",imageView);
////
////    [imageView setImage:[UIImage imageNamed:@"newHomeGQTent"]];
////    [sender.superview addSubview:imageView];
////
////    
////    [sender setAlpha:0.0f];
////    
////    
////    
////    [UIView animateWithDuration:0.3f animations:^{
////        imageView.layer.transform = CATransform3DMakeScale(2, 2, 2);
////      //  [self setAlpha:0.0f];
////        [imageView setAlpha:0.0f];
////
////    } completion:^(BOOL finished) {
////      //  self.select = NO;
////      //  [self setAlpha:1.0f];
////        
////        NSLog(@"imageView - frame--%@",imageView);
////        
////        [sender setAlpha:1.0f];
////
////        [imageView removeFromSuperview];
////        NSLog(@"11111--select = NO--removeFromSuperview;");
////    }];
//
//    
//    
//    
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    WDGNProjectViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGNProjectViewController"];
//    
//    // controller.hidesBottomBarWhenPushed = YES;
//    controller.type = @"1";   // 1就是国内 4是海外
//    [self.navigationController pushViewController:controller animated:YES];
//    
//}

/**
 *  海外项目
 *
 *
 */
//- (IBAction)homeHWXM:(newHomeBtn2 *)sender {
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    WDGNProjectViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGNProjectViewController"];
//    
//    // controller.hidesBottomBarWhenPushed = YES;
//    controller.type = @"4";   // 1就是国内 4是海外
//    [self.navigationController pushViewController:controller animated:YES];
//}

/**
 *  商品众筹
 *
 *
 */
//- (IBAction)homeSPZC:(UIButton *)sender {
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDSPZCViewController"];
//   // controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
//
//    
//}

/**
 *  公益众筹
 *
 *
 */
//- (IBAction)homeGYZC:(UIButton *)sender {
//    
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGYZCViewController"];
//  //  controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
//
//}




#pragma mark - 项目列表
#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    
    [self refreshJX];
    

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
//         NSLog(@"请求成功-refreshJX-%@", responseObject);
         
         //获得数组数组
         NSArray *list = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         countsOfJinxingzhong = list.count;
         
//         NSLog(@"融资阶段： %@",);
         [self.arrAll removeAllObjects];
         
         for (NSDictionary *dict in list) {
             WDShowProject  * model =  [WDShowProject objectWithKeyValues:dict];
             model.programStatus = ProgramJinxingzhong;
             model.mFullImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mFullImageUrl];
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
             
             [self.arrAll addObject:model];
         }
         NSLog(@"请求成功-refreshWC-%@", self.arrAll);
         
         //成功以后就去掉进度框
         //        [MBProgressHUD hideHUDForView:window animated:YES];
         
         [self refreshYR];//预热中
         
         
         
         
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
//         NSLog(@"请求成功-refreshYR-%@", responseObject);
         
         //获得数组数组
         NSArray *list = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         countsOfYurezhong = list.count;
         
         for (NSDictionary *dict in list) {
             WDShowProject  * model =  [WDShowProject objectWithKeyValues:dict];
             model.programStatus = ProgramYurezhong;
             model.mFullImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mFullImageUrl];
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
             
             [self.arrAll addObject:model];
         }
         NSLog(@"请求成功-refreshWC-%@", self.arrAll);
         
         //成功以后我就进度条
         //     [MBProgressHUD hideHUDForView:window animated:YES];
         [self refreshWC];//完成
         
        
         
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
//         NSLog(@"请求成功-refreshWC-%@", responseObject);
         
         //获得数组数组
         NSArray *list = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"jsonArr"];
         
         countsOfWancheng = list.count;
         
         for (NSDictionary *dict in list) {
             WDShowProject  * model =  [WDShowProject objectWithKeyValues:dict];
             model.programStatus = ProgramWancheng;
             model.mFullImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mFullImageUrl];
             model.mSmallImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mSmallImageUrl];
             
             [self.arrAll addObject:model];
         }
         NSLog(@"请求成功-refreshWC-%@", self.arrAll);
         
         
         //成功以后我就进度条
         //      [MBProgressHUD hideHUDForView:window animated:YES];
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         // 拿到当前的下拉刷新控件，结束刷新状态
         [self.tableView.header endRefreshing];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         // [MBProgressHUD hideHUDForView:window animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
}




#pragma mark - 存储数据的models
-(NSMutableArray * )arrAll{
    if (nil == _arrAll) {
        _arrAll = [NSMutableArray array];
    }
    return _arrAll;
    
}

#pragma mark  进行中
-(NSMutableArray * )arrJinxin{
    if (nil == _arrJinxin) {
        _arrJinxin = [NSMutableArray array];
    }
    return _arrJinxin;
    
}

#pragma mark  预热的
-(NSMutableArray * )arrYure{
    if (nil == _arrYure) {
        _arrYure = [NSMutableArray array];
    }
    return _arrYure;
    
}


#pragma mark  完成了
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrAll.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    
    if (self.arrAll.count == 0) {return nil;}
    
    WDShowProject * model = self.arrAll[indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"WDGNProjectJXCell" forIndexPath:indexPath];
    ASProgressPopUpView * progressPopUpView = (ASProgressPopUpView *)[cell viewWithTag:24];
//            [progressPopUpView hidePopUpViewAnimated:NO];
//            [progressPopUpView showPopUpViewAnimated:YES];
    
    progressPopUpView.popUpViewCornerRadius = 8.0;
    progressPopUpView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
    progressPopUpView.dataSource = self;
    
    // 背景图片
    UIImageView * image = [cell viewWithTag:21];
    [image sd_setImageWithURL:[NSURL URLWithString:model.mFullImageUrl] placeholderImage:[UIImage imageNamed:@"default_240_324"]];
    
    NSLog(@"indexPath.row = %ld",(long)indexPath.row);
    //状态标签
    UIImageView * stateTag = [cell viewWithTag:20];
    if (indexPath.row + 1 <= (long)countsOfJinxingzhong) {
        
        [stateTag setImage:[UIImage imageNamed:@"tagJinxin"]];
    }
    else if (countsOfJinxingzhong < indexPath.row + 1 && indexPath.row + 1 <= countsOfYurezhong + countsOfJinxingzhong) {
        
        [stateTag setImage:[UIImage imageNamed:@"tagYure"]];
    }
    else {
        [stateTag setImage:[UIImage imageNamed:@"tagWanchen"]];
    }
    
    
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

    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 350;
}







// 精度条
- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress{
    
    return nil;
    
}






#pragma mark -UITableviewCellsourceDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    WDShowProject * programModel = self.arrAll[indexPath.row];
    
    if (programModel.programStatus == ProgramJinxingzhong) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        zhongchouzhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDjingxingzhongViewController"];
        controller.model = self.arrAll[indexPath.row];
        controller.type = @"jxz";
        controller.userID = userID;
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (programModel.programStatus == ProgramYurezhong) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        yurezhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDyurezhongViewController"];
        controller.model = self.arrAll[indexPath.row];
        controller.userID = userID;
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (programModel.programStatus == ProgramWancheng) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        zhongchouzhongViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDjingxingzhongViewController"];
        controller.model = self.arrAll[indexPath.row];
        controller.type = @"ywc";
        controller.userID = userID;
        [self.navigationController pushViewController:controller animated:YES];
    }
        
    
    
    
}


#pragma mark - 点击分类按钮
- (IBAction)selectGuquan:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
        [self startTransitionAnimationWithDirection:ToLetf];
        self.haiwaiButton.selected = NO;
        
        self.type = @"1";
        [self loadNewData];
    }
    
}

- (IBAction)selectHaiwai:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
        [self startTransitionAnimationWithDirection:ToRight];
        self.guquanButton.selected = NO;
        
        self.type = @"4";
        [self loadNewData];
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    originalX = 120;
    CGFloat lengthOfDash = 100;
    CGFloat originaly = 42;
    
    //画直线
    CGContextMoveToPoint(ctx, screenWidth / 2 - originalX, originaly);
    CGContextAddLineToPoint(ctx, screenWidth / 2 - originalX + lengthOfDash , originaly);
    
    //设置
    CGContextSetLineWidth(ctx, 5);
    CGContextSetRGBStrokeColor(ctx, 31.0/255, 204.0/255, 164.0/255, 0.7);

    
    //渲染
    CGContextStrokePath(ctx);
}

#pragma mark 平移动画
- (void)startTransitionAnimationWithDirection:(direction)direction{

    //1. 创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    CGPoint position = boxLayer.position;
    
    //2. 设置动画
    if (direction == ToLetf) {
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(position.x + originalX, position.y)];
        animation.toValue = [NSValue valueWithCGPoint:position];
    }
    
    if (direction == ToRight) {
        animation.fromValue = [NSValue valueWithCGPoint:position];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(position.x + originalX + 20, position.y)];
        
    }
    
    //要想动画结束之后不返回原来状态，下面两个属性都要设置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    //存储最终的位置，结束时使用
    [animation setValue:animation.toValue forKey:@"WDBasicAnimationLocation"];
    
    animation.duration = 0.5;
    
    //3.添加动画到图层，注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取
    [boxLayer addAnimation:animation forKey:@"KCBasicAnimation_Translation"];
    
    
}


@end

