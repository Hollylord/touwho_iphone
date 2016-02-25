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
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import "UIView+Extension.h"

#import "WDGNProjectViewController.h" //项目
#import "newHomeBtn.h"  // 首页的按钮
#import "newHomeBtn2.h"  // 首页的按钮



#define kMaxSections 10
#define images 4


@interface WDHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *WDpageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *WDCollection;
@property (nonatomic, strong) NSMutableArray *newses;
@property(strong ,nonatomic) NSTimer *timer;


@property (weak, nonatomic) IBOutlet UIView *collectionSuperView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionSuperViewHeihgt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WDPageHeight;

- (IBAction)homeGNXM:(newHomeBtn *)sender;
- (IBAction)homeHWXM:(newHomeBtn2 *)sender;
//- (IBAction)homeSPZC:(UIButton *)sender;
//- (IBAction)homeGYZC:(UIButton *)sender;


//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnConstranit;
//@property (weak, nonatomic) IBOutlet UIButton *constranitBtn;


@end

@implementation WDHomeViewController

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

    // 设置打电话的按钮；
    UIButton * callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect callBtnframe = CGRectMake(0, 0, 27, 27);
    callBtn.frame = callBtnframe;
    [callBtn setBackgroundImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(phoneCall) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:callBtn];
    
    UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect titleBtnframe = CGRectMake(0, 0, 60, 27);
    titleBtn.frame = titleBtnframe;
    titleBtn.userInteractionEnabled = NO;
    [titleBtn setBackgroundImage:[UIImage imageNamed:@"homeLogo"] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleBtn;

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

#pragma mark - 打电话按钮
- (void)phoneCall{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拨打热线电话" message:@"您将拨打投壶网" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    
    
}

#pragma mark - alertview代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *phoneNumber = @"0755-23765675";
        NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    }
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




#warning mark - 首页的四个按钮
/**
 *  国内项目
 *
 *  
 */
- (IBAction)homeGNXM:(newHomeBtn *)sender {
    
//    
//    CGRect newFrame = [sender convertRect:sender.bounds fromView:sender.superview];
//    NSLog(@"newFrame - frame-x-%f--frame-y-%f",newFrame.origin.x,newFrame.origin.y);
//
//    if (newFrame.origin.x < 0) {
//        newFrame.origin.x = -newFrame.origin.x;
//    }
//    if (newFrame.origin.y < 0) {
//        newFrame.origin.y = -newFrame.origin.y;
//    }
//    
//    UIImageView * imageView = [[UIImageView alloc] init];
//    [imageView setFrame:CGRectMake(newFrame.origin.x, newFrame.origin.y, sender.width, sender.height)];
//    
//    NSLog(@"imageView - frame--%@",imageView);
//
//    [imageView setImage:[UIImage imageNamed:@"newHomeGQTent"]];
//    [sender.superview addSubview:imageView];
//
//    
//    [sender setAlpha:0.0f];
//    
//    
//    
//    [UIView animateWithDuration:0.3f animations:^{
//        imageView.layer.transform = CATransform3DMakeScale(2, 2, 2);
//      //  [self setAlpha:0.0f];
//        [imageView setAlpha:0.0f];
//
//    } completion:^(BOOL finished) {
//      //  self.select = NO;
//      //  [self setAlpha:1.0f];
//        
//        NSLog(@"imageView - frame--%@",imageView);
//        
//        [sender setAlpha:1.0f];
//
//        [imageView removeFromSuperview];
//        NSLog(@"11111--select = NO--removeFromSuperview;");
//    }];

    
    
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDGNProjectViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGNProjectViewController"];
    
    // controller.hidesBottomBarWhenPushed = YES;
    controller.type = @"1";   // 1就是国内 4是海外
    [self.navigationController pushViewController:controller animated:YES];
    
}

/**
 *  海外项目
 *
 *
 */
- (IBAction)homeHWXM:(newHomeBtn2 *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDGNProjectViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGNProjectViewController"];
    
    // controller.hidesBottomBarWhenPushed = YES;
    controller.type = @"4";   // 1就是国内 4是海外
    [self.navigationController pushViewController:controller animated:YES];
}

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


-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    if (tab.tabBar.hidden == YES) {
        tab.tabBar.hidden = NO;
    }
}


@end

