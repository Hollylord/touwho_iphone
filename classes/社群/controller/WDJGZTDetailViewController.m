//
//  WDJGZTDetailViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/18.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDJGZTDetailViewController.h"
#import "Reachability.h" // 检测网路状态
#import "MBProgressHUD+MJ.h"
#import "BDTTSSynthesizer.h"
#import "UMSocial.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载

#import "WDOrgListModel.h" // 机构列表

#import "WDInfoTool.h"  // 获取userid
#import "TalkingData.h" // talkdata


#define KreadLength 300


@interface WDJGZTDetailViewController ()<BDTTSSynthesizerDelegate,UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;  // 未播放的按钮
@property (weak, nonatomic) IBOutlet UIButton *lectBtn;  // 播放按钮；


- (IBAction)play:(UIButton *)sender;
- (IBAction)lect:(UIButton *)sender;

//- (IBAction)WDFollowBtn:(UIButton *)sender;
@property (assign ,nonatomic) int numLength;
@property (assign ,nonatomic) int currentLength;
@property (assign,nonatomic)BOOL isWDFollow;

//列表信息；
@property (weak, nonatomic) IBOutlet UIImageView *mLogo; //机构头像
@property (weak, nonatomic) IBOutlet UILabel *mName;  //机构名称
@property (weak, nonatomic) IBOutlet UILabel *mCreatTime;  // 机构创建时间
@property (weak, nonatomic) IBOutlet UITextView *mDestrible;   // 机构简介
@property (weak, nonatomic) IBOutlet UITextView *mContent; //机构内容

@end

@implementation WDJGZTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playBtn.hidden = NO;
    self.lectBtn.hidden = YES;

    
    // 设置活动页面上面的信息；
    [self settingInitContent];

    
    // 初始化合成器
    [self initSynthesizer];
    
    // 请求机构详情；
    [self requestOrgContent];
    
    

    
    self.playBtn.selected = NO;
    self.lectBtn.selected = NO;
    
    self.isWDFollow = NO;

    // 调整textview居中显示的问题；
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    // 设置分享的按钮；
    UIButton * sharedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect sharedBtnframe = CGRectMake(0, 0, 27, 27);
    sharedBtn.frame = sharedBtnframe;
    [sharedBtn setBackgroundImage:[UIImage imageNamed:@"WDsharedBtn"] forState:UIControlStateNormal];
    [sharedBtn addTarget:self action:@selector(sharedBtn) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sharedBtn];
    
    

}


-(void)settingInitContent{
    WDOrgListModel * model = self.orgModel;
    // 设置图片
    [self.mLogo sd_setImageWithURL:[NSURL URLWithString:model.mLogo] placeholderImage:[UIImage imageNamed:@"default_120"]];
    //titile
    [self.mName setText:model.mShortName];
    //创建时间
    [self.mCreatTime setText:model.mCreateTime];
    //机构全称
    [self.mDestrible setText:model.mDestrible];

}


-(void)requestOrgContent{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    // 首先要获得最上面的窗口
   // UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showSuccess:@"正在加载"];
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getOrganizationDetail";
    params[@"org_id"] = self.orgModel.mID;
    
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
      //  [MBProgressHUD hideHUDForView:window animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    params[@"user_id"] = userID;
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    //  NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
   //     [MBProgressHUD hideHUDForView:window animated:YES];
        NSDictionary * dict = [[responseObject objectForKey:@"value"] firstObject];
        self.mContent.text = dict[@"mContent"];
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
            //  NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             [MBProgressHUD showSuccess:@"加载完成"];
            
        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
      //  [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        
    }];
    

    
    
}

#pragma mark - 友盟分享

-(void)sharedBtn{
    NSString * str = [NSString stringWithFormat:@"\n%@\n%@\n",self.orgModel.mShortName,self.orgModel.mLinkUrl];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:str
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];
    

}



#pragma mark - internal function
- (void)initSynthesizer
{
    [BDTTSSynthesizer setLogLevel:BDS_LOG_VERBOSE];
    
    // 设置合成器代理
    [[BDTTSSynthesizer sharedInstance] setSynthesizerDelegate: self];
    
    // 在线相关设置
    
    [[BDTTSSynthesizer sharedInstance] setApiKey:@"49mSqXsIVtHi5HwaObNOduvi" withSecretKey:@"71aa335f1a36c44cb96bdba2e06a3c58"];
    [[BDTTSSynthesizer sharedInstance] setTTSServerTimeOut:10];
    
    // 离线相关设置
    //    NSString *textDataFile =[[NSBundle mainBundle] pathForResource:@"data/bd_etts_ch_text" ofType:@"dat"];
    //    NSString *speechDataFile =[[NSBundle mainBundle] pathForResource:@"data/bd_etts_ch_speech_female" ofType:@"dat"];
    //    [[BDTTSSynthesizer sharedInstance] setOfflineEngineLicense:@"4f2bb6c91f9506fb669032f7868b3754d9ed441e18fe41a794cec63897e340cef731254ab5f9cb831aa76935f9410452d6a78493bd4f74735a0af89eed576045ea31a7a5bbe4c3eea11a97f1c37469990557ad6348c2391f6454046550e0e1d3becf37aaf756d71fd10b8b3fc271ebc6fcbae43a645a32c60bef94ca4919ce2a54bafd3c9ebe2edf612bb536f28b9a771db519e0843155b388f69afa91be62472cf1005339868d5e1af244a137707aa588af1ba03d908a69320d449e38329dede1a0770e6a725a04d4190545b120a9902340c1255c73a6ec08ad731c3f601c4e2efbeccd660c53497009522a94566a14da63bdc6fab1e51e25a7fc6f403bbf39" withAppCode:@"6824376"];
    //
    //
    //
    //    [[BDTTSSynthesizer sharedInstance] setOfflineEngineTextDatPath:textDataFile andSpeechData:speechDataFile];
    
    // 合成参数设置
    [[BDTTSSynthesizer sharedInstance] setSynthesizeParam: BDTTS_PARAM_VOLUME withValue: BDTTS_PARAM_VOLUME_MAX];
    
    // 加载合成引擎
    [[BDTTSSynthesizer sharedInstance] loadTTSEngine];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[BDTTSSynthesizer sharedInstance] cancel];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)play:(UIButton *)sender {
    
    if(![self isEnable3G]){
        [MBProgressHUD showError:@"没有网络"];
        return;
    }
    
    if(![self isEnableWIFI]){
        [MBProgressHUD showError:@"只能WIFI环境下使用"];
        return;
    }
    
    if([self isEnableWIFI]){
        [MBProgressHUD showSuccess:@"开始播放"];
    }
    

    
    
    if(sender.selected == NO)
    {
        sender.hidden = YES;
        self.lectBtn.hidden = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"newsLectClose"] forState:UIControlStateNormal];
        self.numLength =(int) self.textView.text.length;
        
        self.currentLength +=KreadLength;
        int readlength = KreadLength;
        
        if (self.numLength <  KreadLength) {
            readlength = self.numLength;
        }
        
        
        NSString * str = [self.textView.text substringWithRange:NSMakeRange(0, readlength)];
        NSInteger ret = [[BDTTSSynthesizer sharedInstance] speak:str];
        if (ret != BDTTS_ERR_SYNTH_OK) {}
        
    }

}

- (IBAction)lect:(UIButton *)sender {
    if (sender.selected == NO) {
        sender.selected = !sender.selected;
        [sender setBackgroundImage:[UIImage imageNamed:@"newsPause"] forState:UIControlStateNormal];
        [[BDTTSSynthesizer sharedInstance] pause];
        
    }else{
        sender.selected = !sender.selected;
        [sender setBackgroundImage:[UIImage imageNamed:@"newsLect"] forState:UIControlStateNormal];
        [[BDTTSSynthesizer sharedInstance] resume];
    }

}

//- (IBAction)WDFollowBtn:(UIButton *)sender {
//    if (self.isWDFollow == NO) {
//        self.isWDFollow = YES;
//        [sender setTitle:@"关注" forState:UIControlStateNormal];
//    }else{
//        self.isWDFollow = NO;
//        [sender setTitle:@"已关注" forState:UIControlStateNormal];
// 
//    }
//    
//}



-(void)synthesizerSpeechDidFinished{
    
    int readlength = KreadLength;
    int textlength = self.numLength - self.currentLength ;
    if ( textlength >= 0) { // 判断停止；
        
        if (textlength <= KreadLength) {
            readlength = textlength;
        }
        
        
        NSString * str = [self.textView.text substringWithRange:NSMakeRange(self.currentLength, readlength)];
        [[BDTTSSynthesizer sharedInstance] speak:str];
        
        self.currentLength +=KreadLength;
        
    }else{
        
        self.playBtn.hidden = NO;
        self.lectBtn.hidden = YES;
        self.currentLength = 0;
        
        
    }
    
    
}


// 是否WIFI
- (BOOL)isEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否3G WIFI
- (BOOL)isEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * str = [NSString stringWithFormat:@"预热中-项目-%@",self.orgModel.mName];
    [TalkingData trackPageBegin:str];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"预热中-项目-%@",self.orgModel.mName];
    [TalkingData trackPageEnd:str];
}




@end
