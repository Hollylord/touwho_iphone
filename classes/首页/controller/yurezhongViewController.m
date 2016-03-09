//
//  yurezhongViewController.m
//  ad
//
//  Created by apple on 15/7/30.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "yurezhongViewController.h"
#import "ASProgressPopUpView.h"
#import "WDTabBarController.h"
//#import "RNBlurModalView.h"
#import "lingtougentouerror.h"
#import "followSelectedAlert.h"

#import "UMSocial.h"
//#import "speechViewController.h" // 视频
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "WDShowProjectDetail.h" // 项目详情的model


#import "WDInfoTool.h"  // 获取userid
#import "TalkingData.h" // talkdata
#import "RootViewController.h"
#import "WDTopicDetailViewController.h"

// 这个就是上面“项目详情”的高度；
#define KtitleHeight 16
#define Kpadding 64



@interface yurezhongViewController () <ASProgressPopUpViewDataSource,followSelectedAlertdelegate,UMSocialUIDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topImageView; // top背景
@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *mTitle;  //标题
@property (weak, nonatomic) IBOutlet UILabel *mGoalMoney; //目标金额
@property (weak, nonatomic) IBOutlet UILabel *mCurMoney; // 当前金额
@property (weak, nonatomic) IBOutlet UILabel *mScale;   //比率
@property (weak, nonatomic) IBOutlet UITextView *textView1; //项目详情

// 储存当前页面的内容
@property (nonatomic ,strong) WDShowProjectDetail * contentModel;

@property (weak, nonatomic) IBOutlet UIButton *btnProgramDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnInvestAdvice;
@property (weak, nonatomic) IBOutlet UIButton *btnScheme;




@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomHeight;


@property (weak, nonatomic) IBOutlet UIButton *lingtou;
- (IBAction)lingtouBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *gentou;
- (IBAction)gentou:(UIButton *)sender;

- (IBAction)bottomYYZXbtn:(UIButton *)sender;

@property(assign,nonatomic)bool isShowModel;
//@property(strong,nonatomic)RNBlurModalView *modal;


// 上面的关注按钮
@property (assign ,nonatomic) BOOL followSelect;
@property (weak, nonatomic) IBOutlet UIButton *follow;
- (IBAction)followBtn:(UIButton *)sender;


@end


@implementation yurezhongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载页面信息
    [self settingViewContent];

    
    
     self.isShowModel = NO;
        
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kRNBlurDidHidewNotification) name:kRNBlurDidHidewNotification object:nil];
    self.lingtou.selected = NO;
    self.gentou.selected = NO;

    [self rectifyHeight];
    
    // 设置分享的按钮；
    UIButton * sharedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect sharedBtnframe = CGRectMake(0, 0, 27, 27);
    sharedBtn.frame = sharedBtnframe;
    [sharedBtn setBackgroundImage:[UIImage imageNamed:@"WDsharedBtn"] forState:UIControlStateNormal];
    [sharedBtn addTarget:self action:@selector(sharedBtn) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sharedBtn];
    
    self.textView1.textColor = CustomGrayColor;
}



// 加载页面信息
-(void)settingViewContent{
    
    
    
    WDShowProject * model = self.model;
// 能来到这里一定是登录的了
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];

    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

    //获取项目详情内容
    [self settingPojectContent:model.mID andUser:userID];
    
    // 进度条
    [self.progressView hidePopUpViewAnimated:NO];
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


#pragma mark - 获取项目详情
-(void)settingPojectContent:(NSString *)project_id andUser:(NSString *)user_id{
    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
//    
//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
//    [MBProgressHUD showMessage:@"正在加载" toView:window];
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getDetailProject";
    params[@"project_id"] = project_id;
    params[@"user_id"] = user_id;
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        
        //获得数组数组
        NSDictionary *dict = [[responseObject objectForKey:@"value"] firstObject];
        WDShowProjectDetail * model = [WDShowProjectDetail objectWithKeyValues:dict];
        self.contentModel = model;
        self.textView1.text = model.mSummary;  // 项目详情

        
        
        //成功以后我就进度条
      //  [MBProgressHUD hideHUDForView:window animated:YES];
        
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
       // [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        
    }];
    
}



- (void)rectifyHeight{
//    self.scrollViewBottomHeight.constant = 0;
    [self.scrollView layoutIfNeeded];
    
  
}

//- (void)kRNBlurDidHidewNotification{
//    
//    self.lingtou.selected = NO;
//    self.gentou.selected = NO;
//    
//}

#pragma mark - 友盟分享
-(void)sharedBtn{
    NSLog(@"WDsharedBtn");
    
    NSString * str =[NSString stringWithFormat:@"%@\n%@\n",self.model.mTitle,self.contentModel.mProjectUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:str
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]                                       delegate:self];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//-(void)viewWillDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress{
    //默认是数字
    return nil;
}

- (IBAction)lingtouBtn:(UIButton *)sender {
    
//    if (sender.selected == NO) {
//        sender.selected = !sender.selected;
//        lingtougentouerror *error = [[[NSBundle mainBundle] loadNibNamed:@"lingtougentouerror" owner:self options:nil] firstObject];
//        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 90)];
//        
//        // 圆弧的半径
//        view.layer.cornerRadius = 5.f;
//        [view addSubview:error];
//        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self view:view];
//        self.modal = modal;
//        [modal show];
//        self.isShowModel = YES;
//    }
//    self.lingtou = sender;
    
    [MBProgressHUD showError:@"该项目当前状态下不允许投资"];
    
}
- (IBAction)gentou:(UIButton *)sender {
    
//    if (sender.selected == NO) {
//        sender.selected = !sender.selected;
//        lingtougentouerror *error = [[[NSBundle mainBundle] loadNibNamed:@"lingtougentouerror" owner:self options:nil] firstObject];
//        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 90)];
//        
//        // 圆弧的半径
//        view.layer.cornerRadius = 5.f;
//        [view addSubview:error];
//        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self view:view];
//        self.modal = modal;
//        [modal show];
//        self.isShowModel = YES;
//    }
//    self.gentou = sender;
    
    [MBProgressHUD showError:@"该项目当前状态下不允许投资"];

}




//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    if (self.isShowModel == YES) {
//  //      [self.modal hide];
//    }
//}
//

- (IBAction)followBtn:(UIButton *)sender {
    
//    if (self.followSelect == YES) {
//        [self.follow setUserInteractionEnabled:NO];
//        followSelectedAlert *followSelectedAlert = [[[NSBundle mainBundle] loadNibNamed:@"followSelectedAlert" owner:self options:nil] firstObject];
//        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 90)];
//        
//        if ([[UIScreen mainScreen] bounds].size.width > 375) {
//            followSelectedAlert = [[[NSBundle mainBundle] loadNibNamed:@"followSelectedAlert6p" owner:self options:nil] firstObject];
//            view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 90)];
//        }
//        
//        followSelectedAlert.delegate = self;
//        // 圆弧的半径
//        view.layer.cornerRadius = 5.f;
//        [view addSubview:followSelectedAlert];
//        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self view:view];
//        self.modal =  modal;
//        [modal show];
//        
//    }else{
//        self.followSelect = YES;
//        [self.follow setTitle:@"已关注" forState:UIControlStateNormal];
//    }
    
    
}

-(void)followSelectedEnsure{
    self.followSelect = NO;
    [self.follow setTitle:@"关注" forState:UIControlStateNormal];
 //   [self.modal hide];
    [self.follow setUserInteractionEnabled:YES];
}
-(void)followSelectedCancel{
   // [self.modal hide];
    self.followSelect = YES;
    [self.follow setUserInteractionEnabled:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    tab.tabBar.hidden = YES;
    
    NSString * str = [NSString stringWithFormat:@"预热中-项目-%@",self.model.mTitle];
    [TalkingData trackPageBegin:str];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"预热中-项目-%@",self.model.mTitle];
    [TalkingData trackPageEnd:str];
}

#pragma mark - 内容分类按钮
- (IBAction)programDetailClick:(UIButton *)sender {
    self.btnProgramDetail.selected = YES;
    self.btnInvestAdvice.selected = NO;
    self.btnScheme.selected = NO;
    self.textView1.text = self.contentModel.mSummary; // 投资建议
    
    
}
- (IBAction)investAdviceClick:(UIButton *)sender {
    self.btnProgramDetail.selected = NO;
    self.btnInvestAdvice.selected = YES;
    self.btnScheme.selected = NO;
    self.textView1.text = self.contentModel.mSuggest; // 投资建议
}
- (IBAction)planClick:(UIButton *)sender {
    self.btnProgramDetail.selected = NO;
    self.btnInvestAdvice.selected = NO;
    self.btnScheme.selected = YES;
    self.textView1.text =@"";
}

#pragma mark 电话咨询
- (IBAction)telephoneCallClick:(UIButton *)sender {
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


#pragma mark 我要咨询按钮: 跳转到语音聊天
- (IBAction)bottomYYZXbtn:(UIButton *)sender {
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    
    
    WDTopicDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WDTopicDetailViewController"];
    controller.hidesBottomBarWhenPushed = YES;
    controller.topicModel.mID = self.contentModel.mTopicID;
    NSLog(@"topic id = %@",controller.topicModel.mID);
    [self.navigationController pushViewController:controller animated:YES];
    
    
}

@end
