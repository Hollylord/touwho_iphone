//
//  WDTabBarController.m
//  ZBT
//
//  Created by 投壶 on 15/9/28.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDTabBarController.h"
#import "TalkingData.h"

@interface WDTabBarController ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,weak) UIButton *advertButton;
@property (nonatomic,strong) UIImageView * image;

@end

@implementation WDTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.barTintColor = [UIColor colorWithHue:166.0/360 saturation:85.0/100 brightness:80.0/100 alpha:1];
    
    // 首页
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDHomeViewController"];
    
    [self addChildVC:controller title:@"项目" image:@"btn1" selectedImage:@"btn1High"];
    
    
    // 新闻
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"WDnewsViewController"];
    
    [self addChildVC:controller title:@"资讯" image:@"btn2" selectedImage:@"btn2High"];
    
    
    // 发现
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"WDDiscoverViewController"];
    
    [self addChildVC:controller title:@"活动" image:@"btn3" selectedImage:@"btn3High"];
    
    
    
    // 社群
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"WDCommunityTableViewController"];
    
    [self addChildVC:controller title:@"社群" image:@"btn4" selectedImage:@"btn4High"];
    
    
    // 我
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"WDloginTableViewController"];
    
    [self addChildVC:controller title:@"我" image:@"btn5" selectedImage:@"btn5High"];
    
    
    
    //
    NSString * key = @"CFBundleVersion";
    NSString * lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    //
    NSDictionary * info = [NSBundle mainBundle].infoDictionary;
    NSString * currentVersion = info[@"CFBundleVersion"];

    
    if (![lastVersion isEqualToString:currentVersion]) {//
        
        // 显示新特性
        [self showADScrollView];
        // 将当前版本号存进沙盒；
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CFBundleVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        // 只显示蒙版
        [self showWhiteView];
    }


    
    
}

/**
 *  
 *
 */
-(void)addChildVC:(UIViewController *)childVC title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage{
    
    //设置文字
    
    childVC.tabBarItem.title = title;
    childVC.navigationItem.title = title;
    // 上下的名字设置成一样的
    //childVC.title  = title; 这句和上面两句效果一样；
    
    // 设置图片
    
    childVC.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //selectedImage下的 会自动渲染成蓝色；
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置文字样式；
    NSMutableDictionary * textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    [childVC.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary * selectedtextAttrs = [NSMutableDictionary dictionary];
    selectedtextAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:41/255.0f green:170/255.0f blue:141/255.0f alpha:1.0f];
    selectedtextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    [childVC.tabBarItem setTitleTextAttributes:selectedtextAttrs forState:UIControlStateSelected];
    
    //
    [self addChildViewController:childVC];
    
}





-(void)showADScrollView{
    CGRect imageFrame = self.view.frame;
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:imageFrame];
    image.backgroundColor = [UIColor whiteColor];
    //image.alpha = 0.5f;
    [self.view addSubview:image];
    self.image = image;
    
    //创建1个scrollview
    self.scrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(imageFrame.origin.x, imageFrame.origin.y, imageFrame.size.width, imageFrame.size.height)];
    self.scrollView.contentSize = CGSizeMake(imageFrame.size.width * 5, imageFrame.size.height);
    self.scrollView.pagingEnabled = YES;   //这个要开启；
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    
    //创建3个imageview
    int i;
    for (i = 0; i < 5; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(imageFrame.origin.x + i * imageFrame.size.width, imageFrame.origin.y, imageFrame.size.width, imageFrame.size.height);
        NSString *imageName = [NSString stringWithFormat:@"advert%d",i + 1];
        UIImage *image = [UIImage imageNamed:imageName];
        imageView.image = image;
        [self.scrollView addSubview:imageView];
    }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"advertButton"];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake((imageFrame.size.width - 200)/2 + imageFrame.size.width *4, imageFrame.size.height - 150, 200, 100);
        self.advertButton = button;
        [button addTarget:self action:@selector(turnToHomeViewController) forControlEvents:UIControlEventTouchUpInside];
        //一定要把按钮添加到scrollview上面
        [self.scrollView addSubview:self.advertButton];
    
    //创建pagecontrol
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(100, imageFrame.size.height - 50, 100, 30);
    CGPoint center = self.pageControl.center;
    center.x = self.view.center.x;
    self.pageControl.center= center;
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 5;
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pageControl];
    
}


-(void)showWhiteView{
    CGRect imageFrame = self.view.frame;
    UIImageView * image = [[UIImageView alloc] initWithFrame:imageFrame];
    image.backgroundColor = [UIColor whiteColor];
    image.alpha = 0.8f;
    [self.view addSubview:image];
    self.image = image;
    [UIView animateWithDuration:0.5f animations:^{
        self.image.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self.image removeFromSuperview];
    }];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 滑动完毕后的scrollView可以拿到里面的位移；
    CGPoint contentOffset = scrollView.contentOffset;
    int i = contentOffset.x / self.view.frame.size.width;
    CGFloat currentWidth = [UIScreen mainScreen].applicationFrame.size.width;
    if (contentOffset.x <= currentWidth) {
        self.image.alpha = 1.0f;
    }
    
    if (contentOffset.x > currentWidth) {
        self.image.alpha = 0.5f;
    }
    
    if (contentOffset.x > currentWidth*4+50) {
        [self.scrollView removeFromSuperview];
        [self.pageControl removeFromSuperview];
        
        
        
        [UIView animateWithDuration:0.25f animations:^{
            self.image.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [self.image removeFromSuperview];
        }];
        
        
    }
    
    
    self.pageControl.currentPage = i;
}

#pragma mark - 点击按钮
- (void)turnToHomeViewController{
    [self.scrollView removeFromSuperview];
    
    [self.pageControl removeFromSuperview];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.image.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self.image removeFromSuperview];
    }];
}





#pragma mark - 菜单按钮点击

// 让所有基于这个TabBar的视图控制器都只能往竖直方向；
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotate
{
    return NO;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [TalkingData trackPageBegin:@"首页"];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageEnd:@"首页"];
}


@end
