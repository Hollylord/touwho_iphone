//
//  zhongchouzhongViewController.m
//  ad
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "zhongchouzhongViewController.h"

#import "ASProgressPopUpView.h"
//#import "RNBlurModalView.h"
#import "yixianglingtou.h"
#import "yixianggentou.h"
#import "followSelectedAlert.h"
#import "WDTabBarController.h"

#import "UMSocial.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "WDShowProjectDetail.h" // 项目详情的model

//#import "speechViewController.h" // 视频
#import "WDYXLTJinEViewController.h" // 意向金额
#import "touzirenViewController.h" // 意向领头


#import "WDInfoTool.h"  // 获取userid
#import "TalkingData.h" // talkdata


// 下面是一组投资人 和单个投资人
#import "WDAllInvestor.h"
#import "WDInvestorList.h"


// 为了解析
//#import "JSONKit.h"

#import "WDPersonalInfoViewController.h"

#import "RootViewController.h"

#import "UIVideoDiscoverViewController.h" // 蒙版

#import "sponsorCell.h"

// 这个就是上面“项目详情”的高度；
#define KtitleHeight 16
#define Kpadding 64


@interface zhongchouzhongViewController () <ASProgressPopUpViewDataSource,WDlingtouDelegate,WDgentouDelegate,followSelectedAlertdelegate,sponsorsListDelegate,UMSocialUIDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *lingtou;
@property (weak, nonatomic) IBOutlet UIButton *gentou;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


// topview
@property (weak, nonatomic) IBOutlet UIImageView *topImageView; // top背景
@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *mTitle;  //标题
@property (weak, nonatomic) IBOutlet UILabel *mGoalMoney; //目标金额
@property (weak, nonatomic) IBOutlet UILabel *mCurMoney; // 当前金额
@property (weak, nonatomic) IBOutlet UILabel *mScale;   //比率

@property (weak, nonatomic) IBOutlet UIButton *btnProgramDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnInvestAdvice;
@property (weak, nonatomic) IBOutlet UIButton *btnScheme;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *btnInvestors;
@property (weak, nonatomic) IBOutlet UIButton *btnVideo;



//@property (weak, nonatomic) IBOutlet sponsorsList *sponsorsList; // 投资人列表


//@property(strong ,nonatomic) UIButton * gentousender;     // 意向跟头
//@property(strong ,nonatomic) UIButton * lingtousender;  //  意向跟头
- (IBAction)lingtouBtn:(UIButton *)sender;
- (IBAction)gentouBtn:(id)sender;

@property(strong , nonatomic)     yixianglingtou *yixianglingtou;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sponsorListHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roadShowHeight;  // 路演视频的高度


@property (weak, nonatomic) IBOutlet UIView *roadVideo;  // 路演视频的父视图


@property(assign,nonatomic) BOOL Islogin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yuyinzixunBtn;
- (IBAction)bottomYuyinzixunBtn:(UIButton *)sender;


// 上面的关注按钮
@property (assign ,nonatomic) BOOL followSelect;
@property (weak, nonatomic) IBOutlet UIButton *follow;
- (IBAction)followBtn:(UIButton *)sender;

// 储存当前页面的内容
@property (nonatomic ,strong) WDShowProjectDetail * contentModel;


//路演视频
@property (weak, nonatomic) IBOutlet UIWebView *videoShow;



//  投资人列表
@property (nonatomic, strong) NSMutableArray * mFirstInvestor;
@property (nonatomic, strong) NSMutableArray * mFollowInvestor;
@property (nonatomic, strong) NSMutableArray * mLeaderInvestor;
//@property (nonatomic, strong) WDAllInvestor * allInvestor;

//@property (nonatomic ,weak) UIViewController *vc;

@property (nonatomic ,weak) UIVideoDiscoverViewController *vc;



@end

@implementation zhongchouzhongViewController

#pragma mark - 发起人小组
-(NSMutableArray * )mFirstInvestor{
    if (nil == _mFirstInvestor) {
        _mFirstInvestor = [NSMutableArray array];
    }
    return _mFirstInvestor;
    
}

#pragma mark - 跟头人小组
-(NSMutableArray * )mFollowInvestor{
    if (nil == _mFollowInvestor) {
        _mFollowInvestor = [NSMutableArray array];
    }
    return _mFollowInvestor;
    
}

#pragma mark - 领头人小组
-(NSMutableArray * )mLeaderInvestor{
    if (nil == _mLeaderInvestor) {
        _mLeaderInvestor = [NSMutableArray array];
    }
    return _mLeaderInvestor;
    
}

//#pragma mark - 所有小组在一起的
//-(WDAllInvestor * )allInvestor{
//    if (nil == _allInvestor) {
//        _allInvestor = [[WDAllInvestor alloc] init];
//    }
//    return _allInvestor;
//    
//}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 修改titile
    if ([self.type isEqualToString:@"ywc"]) {
        self.navigationItem.title = @"已完成";
    }else {
        self.navigationItem.title = @"进行中";
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"sponsorCell" bundle:nil] forCellReuseIdentifier:@"sponsors"];
    
    // 设置页面信息
    [self settingViewContent];

    
    
    self.navigationController.navigationBarHidden = NO;
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kRNBlurDidHidewNotification) name:kRNBlurDidHidewNotification object:nil];
    self.lingtou.selected = NO;
    self.gentou.selected = NO;
    

    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        self.Islogin = NO;
    }else{
        self.Islogin = YES;

    }

    
    
    // 设置分享的按钮；
    UIButton * sharedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect sharedBtnframe = CGRectMake(0, 0, 27, 27);
    sharedBtn.frame = sharedBtnframe;
    [sharedBtn setBackgroundImage:[UIImage imageNamed:@"WDsharedBtn"] forState:UIControlStateNormal];
    [sharedBtn addTarget:self action:@selector(sharedBtn) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sharedBtn];
//
//    // 是否关注
//    self.followSelect = NO;
//
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillExitFullscreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillShowFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
    
}

// 加载页面信息
-(void)settingViewContent{
    
    WDShowProject * model = self.model;
    
    // 判断下有没有登录
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self settingPojectContent:model.mID andUser:userID];
    
    
    // 进度条
    [self.progressView showPopUpViewAnimated:YES];
    self.progressView.popUpViewCornerRadius = 8.0;
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
    self.progressView.dataSource = self;
    
    // 进度条进度；
    CGFloat scale =[model.mCurMoney floatValue]/[model.mGoalMoney floatValue];
    int scalePer = scale * 100;
    NSString * str1 = [NSString stringWithFormat:@"%d",scalePer];
    scale = [str1 floatValue] / 100.0;
    NSString * str= [NSString stringWithFormat:@"%d%%",scalePer];
    
    // 进度条
    [UIView animateWithDuration:0.25f animations:^{
        [self.progressView setProgress:scale animated:YES];}];

    // 图片
    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:model.mFullImageUrl] placeholderImage:[UIImage imageNamed:@"default_540_274"]];
    
    // 完成率
    [self.mScale setText:str];
    
    // title
    [self.mTitle setText:model.mTitle];
    
    
    // 目标金额
    NSString * tempmGoalMoney =[[NSString alloc] init];
    tempmGoalMoney = [NSString stringWithFormat:@"￥%@万",model.mGoalMoney];
    [self.mGoalMoney setText:tempmGoalMoney];
    
    // 已众筹
    NSString * tempmCurMoney = [[NSString alloc] init];
    tempmCurMoney = [NSString stringWithFormat:@"￥%@万",model.mCurMoney];
    [self.mCurMoney setText:tempmCurMoney];


}


-(void)settingPojectContent:(NSString *)project_id andUser:(NSString *)user_id{
    
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
    params[@"method"] = @"getDetailProject";
    params[@"project_id"] = project_id;
    NSLog(@"--project_id--%@",project_id);
    params[@"user_id"] = user_id;
    NSLog(@"--user_id--%@",user_id);

    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";

    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);

        //获得数组数组
        NSDictionary *dict = [[responseObject objectForKey:@"value"] firstObject];
        WDShowProjectDetail * model = [WDShowProjectDetail objectWithKeyValues:dict];
        self.contentModel = model;
        self.textView.text = model.mSummary;

        
        // 领投人

          NSArray *arrlist = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"mFirstInvestor"];
       // NSArray *arrlist=[jsonString objectFromJSONString];
        
        for (NSDictionary * dict in arrlist) {
            WDInvestorList * model =  [WDInvestorList objectWithKeyValues:dict];
            
            NSLog(@"-mFirstInvestor--mid-%@",model.mID);
            NSLog(@"-mFirstInvestor--mName-%@",model.mName);
            
//            NSString * str = model.mName;
//            NSRange range = NSMakeRange(0, 1);
//            str = [str substringWithRange:range];
//            model.mName = [NSString stringWithFormat:@"%@**",str];
            
            model.mAvatar = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mAvatar];
            NSLog(@"-mFirstInvestor--mAvatar-%@", model.mAvatar);
            NSLog(@"-mFirstInvestor--mInvestMoney-%@", model.mInvestMoney);
            [self.mFirstInvestor addObject:model];
        }
        
        // 跟头人
        NSArray *arrlist2 = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"mFollowInvestor"];
      //  NSArray *arrlist2 =[jsonString2 objectFromJSONString];
        
        for (NSDictionary * dict in arrlist2) {
            WDInvestorList * model =  [WDInvestorList objectWithKeyValues:dict];
            
            NSLog(@"-mFollowInvestor--mid-%@",model.mID);
            NSLog(@"-mFollowInvestor--mName-%@",model.mName);
            NSString * str = model.mName;
            NSRange range = NSMakeRange(0, 1);
            str = [str substringWithRange:range];
            model.mName = [NSString stringWithFormat:@"%@**",str];

            model.mAvatar = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mAvatar];
            NSLog(@"-mFollowInvestor--mAvatar-%@", model.mAvatar);
            NSLog(@"-mFollowInvestor--mInvestMoney-%@", model.mInvestMoney);
            
            [self.mFollowInvestor addObject:model];
        }

         // 发起人
          NSArray *arrlist3 = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"mLeaderInvestor"];
       // NSArray *arrlist3 = [jsonString3 objectFromJSONString];
        
        for (NSDictionary * dict in arrlist3) {
            WDInvestorList * model =  [WDInvestorList objectWithKeyValues:dict];
            
            NSLog(@"-mLeaderInvestor--mid-%@",model.mID);
            NSLog(@"-mLeaderInvestor--mName-%@",model.mName);
//            NSString * str = model.mName;
//            NSRange range = NSMakeRange(0, 1);
//            str = [str substringWithRange:range];
//            model.mName = [NSString stringWithFormat:@"%@**",str];
            model.mAvatar = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mAvatar];
            NSLog(@"-mLeaderInvestor--mAvatar-%@", model.mAvatar);
            NSLog(@"-mLeaderInvestor--mInvestMoney-%@", model.mInvestMoney);
            model.mInvestMoney = @""; // 发起人不用投钱
            [self.mLeaderInvestor addObject:model];
        }

        
        
        WDAllInvestor * allInvestor = [[WDAllInvestor alloc] init];
        allInvestor.mFirstInvestor = [NSArray arrayWithArray:self.mFirstInvestor];
        allInvestor.mFollowInvestor = [NSArray arrayWithArray:self.mFollowInvestor];
        allInvestor.mLeaderInvestor = [NSArray arrayWithArray:self.mLeaderInvestor];
       // self.allInvestor = allInvestor;

        // 设置内嵌的tableView
//        self.sponsorsList.allInvestor = allInvestor;
        
        //加载数据
        [self.tableView reloadData];
        
        //视频
        NSURL * url =[NSURL URLWithString:model.mVideo];
        //NSLog(@"model.mVideo-%@",model.mVideo);
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.videoShow loadRequest:request];
        self.videoShow.scalesPageToFit = YES;
        // webView.contentScaleFactor = NO;
        //NSLog(@"---self.videoShow.subviews---%@--",self.videoShow.subviews);
        UIScrollView *tempView=(UIScrollView *)[self.videoShow.subviews objectAtIndex:0];
        tempView.scrollEnabled=NO;

        

        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        

        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
        [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];

        
    }];
    
}

-(void)rectifyHeight{
    
    if([UIScreen mainScreen].applicationFrame.size.width == 414 ){  // 6p
        self.roadShowHeight.constant = 250;
        [self.roadVideo layoutIfNeeded];
    }
    if([UIScreen mainScreen].applicationFrame.size.width == 375){   // 6
        self.roadShowHeight.constant = 225;
        [self.roadVideo layoutIfNeeded];

    }
    if([UIScreen mainScreen].applicationFrame.size.width ==320 ){  // 5,4
        self.roadShowHeight.constant = 195;
        [self.roadVideo layoutIfNeeded];
    }
    
    [self.scrollView layoutIfNeeded];
    
    
    // 设置下投资人列表的代理
//    self.sponsorsList.delegate = self;
 
}


#pragma mark - 友盟分享
-(void)sharedBtn{
    NSLog(@"WDsharedBtn");
    NSString * str =[NSString stringWithFormat:@"%@\n%@\n",self.model.mTitle,self.contentModel.mProjectUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:str
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    tab.tabBar.hidden = YES;

    //设置约束
    [self rectifyHeight];
    
    
    
    NSString * str = [NSString stringWithFormat:@"进行中-项目-%@",self.model.mTitle];
    [TalkingData trackPageBegin:str];

}



- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress{
    //默认是数字
    return nil;
}



#pragma mark - 领头按钮
- (IBAction)lingtouBtn:(UIButton *)sender {
    
    if ([self.type isEqualToString:@"ywc"]) {
        [MBProgressHUD showError:@"该项目已经完成"];
        return;
    }
    
    BOOL isCanInvestor = [WDInfoTool isCanInvestor];
    if (!isCanInvestor) {
        [MBProgressHUD showError:@"请完善个人信息"];
        return;
    }
    
    
    

    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    NSString * mIsFirstInvestor = [WDInfoTool mIsFirstInvestor];
    if ([mIsFirstInvestor isEqualToString:@"0"]) {
        [MBProgressHUD showError:@"请申请为领头人"];
        // 申请成为领头人
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        touzirenViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDtouzirenViewController"];
        controller.mID = userID;
        [self.navigationController pushViewController:controller animated:YES];

    }

    if ([mIsFirstInvestor isEqualToString:@"1"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDYXLTJinEViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WDYXLTJinEView"];
        viewController.user_id = userID;
        viewController.project_id =  self.model.mID ;
        viewController.type = @"yixianglingtou";
        viewController.mMaxInvest = self.contentModel.mMaxInvest;
        viewController.mMinInvest = self.contentModel.mMinInvest;
        [self.navigationController pushViewController:viewController animated:YES];
    }

    
}


#pragma mark - 跟头按钮就是投资人的按钮
- (IBAction)gentouBtn:(UIButton *)sender {
    if ([self.type isEqualToString:@"ywc"]) {
        [MBProgressHUD showError:@"该项目已经完成"];
        return;
    }
    
    BOOL isCanInvestor = [WDInfoTool isCanInvestor];
    if (!isCanInvestor) {
        [MBProgressHUD showError:@"请完善个人信息"];
        return;
    }
    
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    NSString * mIsInvestor = [WDInfoTool mIsInvestor];
    if ([mIsInvestor isEqualToString:@"0"]) {
        [MBProgressHUD showError:@"请先申请为投资人"];
        // 申请成为投资人
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        touzirenViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDlingtourenViewController"];
        controller.mID = userID;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
    if ([mIsInvestor isEqualToString:@"1"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDYXLTJinEViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WDYXLTJinEView"];
        viewController.user_id = userID;
        viewController.project_id =  self.model.mID ;
        viewController.type = @"yixianggentou";
        viewController.mMaxInvest = self.contentModel.mMaxInvest;
        viewController.mMinInvest = self.contentModel.mMinInvest;
        [self.navigationController pushViewController:viewController animated:YES];
    }

    
}



#pragma mark - 语音咨询
- (IBAction)bottomYuyinzixunBtn:(UIButton *)sender {
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

    
    RootViewController * controller = [[RootViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.tag_ID = @"66";
    controller.userID = userID;
    [self.navigationController pushViewController:controller animated:YES];
    
}





//  以下是关注按钮的
//- (IBAction)followBtn:(UIButton *)sender {
//    
//    if (self.followSelect == YES) {
//        
//        [self.follow setUserInteractionEnabled:NO];
//        
//        followSelectedAlert *followSelectedAlert = [[[NSBundle mainBundle] loadNibNamed:@"followSelectedAlert" owner:self options:nil] firstObject];
//        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 90)];
//        
//        if ([[UIScreen mainScreen] bounds].size.width > 375) {
//            followSelectedAlert = [[[NSBundle mainBundle] loadNibNamed:@"followSelectedAlert6p" owner:self options:nil] firstObject];
//            view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 90)];
//        }
//        
//        
//        followSelectedAlert.delegate = self;
//        // 圆弧的半径
//        view.layer.cornerRadius = 5.f;
//        [view addSubview:followSelectedAlert];
//        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self view:view];
//        self.modal =  modal;
//        [modal show];
//        
//        
//    }else{
//        self.followSelect = YES;
//        [self.follow setTitle:@"已关注" forState:UIControlStateNormal];
//    }
//    
//    
//}
//
//-(void)followSelectedEnsure{
//    self.followSelect = NO;
//    [self.follow setTitle:@"关注" forState:UIControlStateNormal];
//
//    [self.modal hide];
//    [self.follow setUserInteractionEnabled:YES];
//
//}
//-(void)followSelectedCancel{
//    [self.modal hide];
//    self.followSelect = YES;
//    [self.follow setUserInteractionEnabled:YES];
//
//}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"进行中-项目-%@",self.model.mTitle];
    [TalkingData trackPageEnd:str];
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

#pragma mark - 内容分类按钮
- (IBAction)programDetailClick:(UIButton *)sender {
    self.btnProgramDetail.selected = YES;
    self.btnInvestAdvice.selected = NO;
    self.btnScheme.selected = NO;
    self.textView.text = self.contentModel.mSummary; // 投资建议
}
- (IBAction)investAdviceClick:(UIButton *)sender {
    self.btnProgramDetail.selected = NO;
    self.btnInvestAdvice.selected = YES;
    self.btnScheme.selected = NO;
    self.textView.text = self.contentModel.mSuggest; // 投资建议
}
- (IBAction)planClick:(UIButton *)sender {
    self.btnProgramDetail.selected = NO;
    self.btnInvestAdvice.selected = NO;
    self.btnScheme.selected = YES;
    self.textView.text =@"";
}

#pragma mark - 投资人列表
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[[NSBundle mainBundle]loadNibNamed:@"BTHeaderView" owner:self options:nil] firstObject];
        return view;
    }
    else {
        return nil;
    }
}

#pragma mark - tableview 代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.mLeaderInvestor.count;
    }
    else if(section == 1){
        return self.mFirstInvestor.count;
    }
    else {
        return self.mFollowInvestor.count;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    sponsorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sponsors"];
    
    // 发起人
    if(indexPath.section == 0){
        WDInvestorList * model = self.mLeaderInvestor[indexPath.row];
        cell.type = @"fqr";
        cell.model = model;
        NSLog(@"dequeueReusableCellWithIdentifier-sponsors-%@",model.mName);
        
        
    }
    
    // 领投人
    if(indexPath.section == 1){
        WDInvestorList * model = self.mFirstInvestor[indexPath.row];
        cell.type = @"ltr";
        cell.model = model;
        NSLog(@"dequeueReusableCellWithIdentifier-sponsors-%@",model.mName);
        
        
        
    }
    // 跟投人
    if(indexPath.section == 2){
        WDInvestorList * model = self.mFollowInvestor[indexPath.row];
        cell.type = @"gtr";
        cell.model = model;
        NSLog(@"dequeueReusableCellWithIdentifier-sponsors-%@",model.mName);
        
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"sponsorsListdidSelectRowAtIndexPath -- %ld",(long)indexPath.section);
    
    NSLog(@"sponsorsListdidSelectRowAtIndexPath -- %ld",(long)indexPath.row);
    
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    
    
    // 发起人
    if(indexPath.section == 0){
        WDInvestorList * model = self.mLeaderInvestor[indexPath.row];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
        
        controller.user_id = userID;
        controller.target_id = model.mID;
        controller.target_iconUrl = model.mAvatar;
        [self.navigationController pushViewController:controller animated:YES];
        
        
        
    }
    
    // 领投人
    if(indexPath.section == 1){
        WDInvestorList * model = self.mFirstInvestor[indexPath.row];
        
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
        
        controller.user_id = userID;
        controller.target_id = model.mID;
        controller.target_iconUrl = model.mAvatar;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    // 跟投人
    if(indexPath.section == 2){
        WDInvestorList * model = self.mFollowInvestor[indexPath.row];
        
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
        
        controller.user_id = userID;
        controller.target_id = model.mID;
        controller.target_iconUrl = model.mAvatar;
        [self.navigationController pushViewController:controller animated:YES];
        
    }

    
}


-(void)setAllInvestor:(WDAllInvestor *)allInvestor{
    // self.mFirstInvestor = allInvestor.mFirstInvestor;
    //    self.mFollowInvestor = allInvestor.mFollowInvestor;
    //    self.mLeaderInvestor = allInvestor.mLeaderInvestor;
    //
    self.mFirstInvestor = [NSArray arrayWithArray:allInvestor.mFirstInvestor];
    self.mFollowInvestor = [NSArray arrayWithArray:allInvestor.mFollowInvestor];
    self.mLeaderInvestor = [NSArray arrayWithArray:allInvestor.mLeaderInvestor];
    
    [self.tableView reloadData];
}

#pragma mark - 投资人列表和路演视频切换按钮
- (IBAction)investorsClick:(UIButton *)sender {
    self.btnInvestors.selected = YES;
    self.btnVideo.selected = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        for (NSLayoutConstraint *constraintX in self.scrollView.constraints) {
            if ([constraintX.identifier isEqualToString:@"videoLeading"]) {
                constraintX.constant = 0;
            }
        }
        [self.videoShow layoutIfNeeded];
    }];
}

- (IBAction)videoClick:(UIButton *)sender {
    self.btnInvestors.selected = NO;
    self.btnVideo.selected = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        for (NSLayoutConstraint *constraintX in self.scrollView.constraints) {
            if ([constraintX.identifier isEqualToString:@"videoLeading"]) {
                constraintX.constant = -self.videoShow.bounds.size.width;
            }
        }
        [self.videoShow layoutIfNeeded];
    }];
    
    
    
    
}

#pragma mark - 电话咨询
- (IBAction)telephoneClick:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拨打热线电话" message:@"您将拨打投壶网" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *phoneNumber = @"0755-23765675";
        NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    }
}

@end
