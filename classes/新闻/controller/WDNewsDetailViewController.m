//
//  WDNewsDetailViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDNewsDetailViewController.h"

#import "BDTTSSynthesizer.h"
#import "WDTabBarController.h"
#import "Reachability.h" // 检测网路状态

#import "MBProgressHUD+MJ.h"

#import "UMSocial.h"
#import "newsContent.h"
#import "newsDetailContent.h"
#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>


#import "WDInfoTool.h"  // 获取userid

#import "TalkingData.h" // talkdata


// 这个就是上面“项目详情”的高度；
#define KtitleHeight 600
#define KreadLength 300


@interface WDNewsDetailViewController () <BDTTSSynthesizerDelegate,UMSocialUIDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteDistance;
@property (weak, nonatomic) IBOutlet UIView *whiteView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteViewHeight;


@property (copy , nonatomic)  NSString * currentText;
@property (assign ,nonatomic) int numLength;
@property (assign ,nonatomic) int currentLength;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
- (IBAction)playBtn:(UIButton *)sender;
- (IBAction)newsLect:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *LectBtn;

// 点赞
@property (assign,nonatomic) BOOL iSdianzan;
@property (weak, nonatomic) IBOutlet UIButton *dianzhanB;
- (IBAction)dianzanA:(id)sender;

// 赞的数字
@property (weak, nonatomic) IBOutlet UILabel *zanCount;

// 底部按钮
- (IBAction)zhuanfaBtnA:(id)sender;
- (IBAction)dianzanBtnA:(id)sender;



// 全局存放新闻数据
@property (strong ,nonatomic) newsDetailContent * modelDetail;

@end

@implementation WDNewsDetailViewController

//-(void)setModel:(newsContent *)model{
//    self.model = [[newsContent alloc] init];
//    self.model = model;
//}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置初始的状态；
    self.LectBtn.hidden = NO;
    self.playBtn.hidden = YES;
    self.iSdianzan = NO;
    self.LectBtn.selected = NO;
    self.playBtn.selected = NO;

    

//    //添加全局变量
//    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
//    userID = [user objectForKey:@"userID"];
//
//    NSLog(@"userID = [user objectForKey---%@",userID);
    
    // 设置内容
    [self initModelContent];
    
    
    self.whiteDistance.constant = 60;
    [self.scrollView layoutIfNeeded];
    
    
    // 初始化合成器
    [self initSynthesizer];
    
}


-(void)initModelContent{
//    NSLog(@"dfjkhdsjkfhsdkjfhkdsjhfkdjshfkjsdhkfjds");
//    
//    //设置参数
//    NSDictionary *params;
//    if (!userID) {
//        params = @{@"method":@"getNewsContent",@"news_id":mId};
//    }
//    else{
//        params = @{@"method":@"getNewsContent",@"news_id":mId,@"user_id":userID};
//    }
    
    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    
//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
   [MBProgressHUD showSuccess:@"正在加载"];
//    
//
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getNewsContent";
    params[@"news_id"] = self.model.mID;
   // params[@"user_id"] = @"0";


    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099/";

    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         // 请求成功的时候调用这个block
         NSLog(@"请求成功--%@", responseObject);
         
         
         //获得新闻数组
         NSArray * newContent = [responseObject objectForKey:@"value"];
         NSDictionary *dict = [newContent firstObject];
         
         newsDetailContent * modelDetail =  [newsDetailContent objectWithKeyValues:dict];
         //         //设置top图片

         if (![dict[@"mLargeImageUrl"]isEqualToString:@""]) {
            modelDetail.mLargeImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,[dict objectForKey:@"mLargeImageUrl"]];
         }else{
             UIImageView * topImage = (UIImageView *)[self.view viewWithTag:24];

             [topImage removeFromSuperview];
             
         }
         //         // 设置bottom图片

         if (![dict[@"mBottomImageUrl"]isEqualToString:@""]) {
             modelDetail.mBottomImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,[dict objectForKey:@"mBottomImageUrl"]];

         }else{
              UIImageView * bottomImage = (UIImageView *)[self.view viewWithTag:26];
             [bottomImage removeFromSuperview];
         }
         
         
         
         self.modelDetail = modelDetail;
         
         //设置标题；
         UILabel * title = (UILabel *)[self.view viewWithTag:22];
         title.text = self.model.mTitle;
         
         // 设置时间
         UILabel * time = (UILabel *)[self.view viewWithTag:23];
         time.text = self.model.mCreateTime;
         
         //设置top图片
         if(![modelDetail.mLargeImageUrl isEqualToString:@""]){
             UIImageView * topImage = (UIImageView *)[self.view viewWithTag:24];
             NSURL * imageUrl = [NSURL URLWithString:modelDetail.mLargeImageUrl];
             [topImage sd_setImageWithURL:imageUrl];

         }
         
         // 设置bottom图片
         if(![modelDetail.mBottomImageUrl isEqualToString:@""]){
             UIImageView * bottomImage = (UIImageView *)[self.view viewWithTag:26];
             NSURL * imageUrl = [NSURL URLWithString:modelDetail.mBottomImageUrl];
             [bottomImage sd_setImageWithURL:imageUrl];
             
         }

         
         //设置文本；
         UITextView * text = (UITextView *)[self.view viewWithTag:25];
         text.text = modelDetail.mContent;
         
         
         
         
         // 点赞数量
         [self.zanCount setText:modelDetail.mPraiseCount];
         
         //成功以后我就进度条
    //     [MBProgressHUD hideHUDForView:window animated:YES];


     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
      //   [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];

     }];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //设置top图片
    UIImageView * topImage = (UIImageView *)[self.view viewWithTag:24];
    if([self.modelDetail.mLargeImageUrl isEqualToString:@""]){
        [topImage removeFromSuperview];
    }

    
  // 设置bottom图片
  UIImageView * bottomImage = (UIImageView *)[self.view viewWithTag:26];
    if([self.modelDetail.mBottomImageUrl isEqualToString:@""]){
        [bottomImage removeFromSuperview];
        
   }
    
    WDTabBarController * tabBar = (WDTabBarController *) self.tabBarController;
    tabBar.tabBar.hidden = YES;


}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    WDTabBarController * tabBar = (WDTabBarController *) self.tabBarController;
    tabBar.tabBar.hidden = YES;
    
    NSString * str = [NSString stringWithFormat:@"新闻-标题-%@",self.model.mTitle];
    [TalkingData trackPageBegin:str];
    
    //设置top图片
    UIImageView * topImage = (UIImageView *)[self.view viewWithTag:24];
    if([self.modelDetail.mLargeImageUrl isEqualToString:@""]){
        [topImage removeFromSuperview];
    }
    
    
    // 设置bottom图片
    UIImageView * bottomImage = (UIImageView *)[self.view viewWithTag:26];
    if([self.modelDetail.mBottomImageUrl isEqualToString:@""]){
        [bottomImage removeFromSuperview];
        
    }


}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   [[BDTTSSynthesizer sharedInstance] cancel];

}


- (IBAction)playBtn:(UIButton *)sender {
    
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

- (IBAction)newsLect:(UIButton *)sender {
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
        self.playBtn.hidden = NO;
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
        
        self.playBtn.hidden = YES;
        self.LectBtn.hidden = NO;
        self.currentLength = 0;
    }
    

    
}


//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    WDTabBarController * tabBar = (WDTabBarController *) self.tabBarController;
//        tabBar.tabBar.hidden = YES;
//}

- (IBAction)dianzanA:(id)sender {
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请登录"];
        return;
    }

    
    NSString * text = self.zanCount.text;
    int intString = [text intValue];

    if (self.iSdianzan == NO) {
        self.iSdianzan = YES;
        [self.dianzhanB setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
        intString++;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
        [self updianzan:@"zen"];
    }else{
        self.iSdianzan = NO;
       [self.dianzhanB setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        intString--;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];

        [self updianzan:@"jian"];
    }
    
}
#pragma mark - 友盟分享

- (IBAction)zhuanfaBtnA:(id)sender {
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:@"你要分享的文字"
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];


}

- (IBAction)dianzanBtnA:(id)sender {
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请登录"];
        return;
    }

    
    NSString * text = self.zanCount.text;
    int intString = [text intValue];
    
    if (self.iSdianzan == NO) {
        self.iSdianzan = YES;
        [self.dianzhanB setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
        intString++;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
        [self updianzan:@"zen"];
    }else{
        self.iSdianzan = NO;
        [self.dianzhanB setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        intString--;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
        
        [self updianzan:@"jian"];

    }

}



#pragma mark 点赞
-(void)updianzan:(NSString *)type{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    

//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
//    [MBProgressHUD showMessage:@"正在加载" toView:window];
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([type isEqualToString:@"zen"]) {
        params[@"method"] = @"praiseNews";
        NSLog(@"zen");
    }else{
        params[@"method"] = @"cancelPraiseNews";
        NSLog(@"jian");
        
    }
    params[@"news_id"] = self.model.mID;
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    params[@"user_id"] = userID;

    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
   //     [MBProgressHUD hideHUDForView:window animated:YES];
        
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
            NSString * str = @"已成功点赞";
            if ([type isEqualToString:@"jian"]) {
              str = @"已取消点赞";
             }
            [MBProgressHUD showSuccess:str];
            
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

// 是否WIFI
- (BOOL)isEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否3G WIFI
- (BOOL)isEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"新闻-标题-%@",self.model.mTitle];
    [TalkingData trackPageEnd:str];
}


@end
