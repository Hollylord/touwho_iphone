//
//  WDActivityDetalController.m
//  ZBT
//
//  Created by 投壶 on 15/10/26.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDActivityDetalController.h"
#import "WDActivityDetailModel.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "UMSocial.h"

#import "WDInfoTool.h"  // 获取userid
#import "TalkingData.h" // talkdata


#import "activityViewController.h"

@interface WDActivityDetalController ()<UMSocialUIDelegate>


- (IBAction)chakanMap:(id)sender;

//赞
@property (weak, nonatomic) IBOutlet UIButton *zanbtn;
@property (weak, nonatomic) IBOutlet UILabel *zanCount;
@property (assign,nonatomic) BOOL iSdianzan;
- (IBAction)zanbtnA:(id)sender;

//下面的按钮
- (IBAction)zhuanfaBtn:(id)sender;
- (IBAction)BottomZanBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *mTitle; //活动标题
@property (weak, nonatomic) IBOutlet UILabel *mTime;  // 活动时间
@property (weak, nonatomic) IBOutlet UITextView *mAddress;  // 活动地址
@property (weak, nonatomic) IBOutlet UITextView *mContentText;  //活动内容

//保存当前页面的详情
@property (strong ,nonatomic) WDActivityDetailModel * detailModel;

@property (weak, nonatomic) IBOutlet UIButton *baoming;

- (IBAction)baomingClick:(id)sender;

@end

@implementation WDActivityDetalController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iSdianzan = NO;

    // 如果是已经进行或者结束的隐藏报名按钮
    if (![self.model.mStatus isEqualToString:@"0"]) {
        NSLog(@" if (![self.model.mStatus isEqualToStri");
        NSLog(@"------%@",self.model.mStatus);
        self.baoming.hidden = YES;
    }

    
    // 设置活动页面上面的信息；
    [self settingInitContent];
    
    
    // 请求活动详情；
    [self requestActivityContent];
    
    
}


-(void)settingInitContent{
    WDActivityListModel * model = self.model;
    self.mTitle.text = model.mTitle;
    self.mTime.text = model.mTime;
    self.mAddress.text = model.mAddress;
}


-(void)requestActivityContent{
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
    params[@"method"] = @"getActivityDetail";
    params[@"activity_id"] = self.model.mID;

    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
  //  NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
      //  [MBProgressHUD hideHUDForView:window animated:YES];
        NSDictionary * dict = [[responseObject objectForKey:@"value"] firstObject];
        
        WDActivityDetailModel * detailModel = [WDActivityDetailModel objectWithKeyValues:dict];
        self.detailModel = detailModel;
        self.mContentText.text = detailModel.mContent;
        
        if([self.model.mStatus isEqualToString:@"0"]&&[detailModel.mIsRegActivity isEqualToString:@"1"]){
            self.baoming.hidden = NO;
            [self.baoming setTitle:@"已报名" forState:UIControlStateNormal];
            self.baoming.userInteractionEnabled = NO;
        }
        
        if([self.model.mStatus isEqualToString:@"0"]&&[detailModel.mIsRegActivity isEqualToString:@"0"]){
            self.baoming.hidden = NO;
            [self.baoming setTitle:@"报名活动" forState:UIControlStateNormal];
            self.baoming.userInteractionEnabled = YES;
        }

        
//        //成功
//        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
//          //  NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
//         // [MBProgressHUD showSuccess:@""];
//            
//        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
    //    [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)chakanMap:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    activityViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"activityDetail"];
    controller.mTime = self.mTime.text;
    controller.mTitle = self.mTitle.text;
    controller.mAddress = self.mAddress.text;
    [self.navigationController pushViewController:controller animated:YES];
}







- (IBAction)zanbtnA:(id)sender {
    NSString * text = self.zanCount.text;
    int intString = [text intValue];
    
    if (self.iSdianzan == NO) {
        self.iSdianzan = YES;
        [self.zanbtn setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
        intString++;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
    }else{
        self.iSdianzan = NO;
        [self.zanbtn setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        intString--;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
        
    }

    
}
#pragma mark - 友盟分享
- (IBAction)zhuanfaBtn:(id)sender {
    NSString * str = [NSString stringWithFormat:@"活动主题:\n%@\n\n活动时间:\n%@\n\n活动地址:\n%@\n\n公司主页:\nhttp://www.touwho.com\n",self.model.mTitle,self.model.mTime,self.model.mAddress];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:str
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];

}

- (IBAction)BottomZanBtn:(id)sender {
    NSString * text = self.zanCount.text;
    int intString = [text intValue];
    
    if (self.iSdianzan == NO) {
        self.iSdianzan = YES;
        [self.zanbtn setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
        intString++;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
    }else{
        self.iSdianzan = NO;
        [self.zanbtn setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        intString--;
        self.zanCount.text = [NSString stringWithFormat:@"%d",intString];
        
    }

}
- (IBAction)baomingClick:(id)sender {
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

    
    
    // 1. 创建一个请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes  = [NSSet setWithObject:@"text/html"];
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:window];

    
    //2.字典
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"method"] = @"activityReg";
    params[@"user_id"] = userID;
    params[@"activity_id"] = self.model.mID;
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    //  NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];

        
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
              NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
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
        
        [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        

        
        
    }];
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * str = [NSString stringWithFormat:@"活动-%@",self.model.mTitle];
    [TalkingData trackPageBegin:str];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"活动-%@",self.model.mTitle];
    [TalkingData trackPageEnd:str];
}

@end
