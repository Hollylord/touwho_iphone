//
//  dengluViewController.m
//  ad
//
//  Created by apple on 15/7/23.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "dengluViewController.h"
#import "UMSocial.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import <AFNetworking.h>
#import "WDMyInfo.h"
#import  <MJExtension.h> // 字典转模型

#import "WDInfoTool.h"  // 用户信息存沙盒的工具

#import <CommonCrypto/CommonDigest.h>   // MD5

@interface dengluViewController ()<UITextFieldDelegate>


- (IBAction)weiboBtn:(id)sender;
- (IBAction)weixinBtn:(UIButton *)sender;
- (IBAction)qqBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *passworld;

- (IBAction)login:(id)sender;


@end

@implementation dengluViewController
//{
//    AFHTTPRequestOperationManager *mgr;
//}


#pragma mark -MD5转成
-(NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.username.text = nil;
    self.passworld.text = nil;
    
    self.username.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passworld.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    if(__IPHONE_8_0 | __IPHONE_7_0){
       self.passworld.tintColor=[UIColor blueColor];
        self.username.tintColor=[UIColor blueColor];
    }
    
    
    
    self.username.delegate = self;
    self.passworld.delegate = self;
    
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelLogin)];
    
    
    UIImageView * registerPhone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerPhone"]];
    registerPhone.width = 30;
    registerPhone.height = 30;
    registerPhone.contentMode = UIViewContentModeCenter; // 让放大镜居中；
    self.username.leftView = registerPhone;
    self.username.leftViewMode = UITextFieldViewModeAlways; // 这个一定要设置，因为默认是不显示；

    
    UIImageView * registerPassworld = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerPassworld"]];
    registerPassworld.width = 30;
    registerPassworld.height = 30;
    registerPassworld.contentMode = UIViewContentModeCenter; // 让放大镜居中；
    self.passworld.leftView = registerPassworld;
    self.passworld.leftViewMode = UITextFieldViewModeAlways; // 这个一定要设置，因为默认是不显示；

    
}


-(void)cancelLogin{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的密码错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil] ;
//    [alert  show];
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:nil
//                                      shareText:@"友盟社会化分享让您快速实现分享等社会化功能，www.umeng.com/social"
//                                     shareImage:[UIImage imageNamed:@"icon.png"]
//                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite]
//                                       delegate:nil];
//    
//     //self.view.
    
    [self.view endEditing:YES];

    
  
}
//实现回调方法（可选）：
//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
//{
//    //根据`responseCode`得到发送结果,如果分享成功
//    if(response.responseCode == UMSResponseCodeSuccess)
//    {
//        //得到分享到的微博平台名
//        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
//    }
//}
//
#pragma mark - 微博快捷登陆
- (IBAction)weiboBtn:(id)sender {

    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    //判断是否需要授权
    if (snsPlatform.needLogin) {
        
        
        
        NSLog(@"微博还未授权了");

        
        //弹出授权处理页面   处理点击登录事件后的block对象

        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            NSLog(@"还未授权%@",response);
            
            //          获取微博用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
                
            NSLog(@"username--%@, uid--%@, token--%@ url--%@ type--微博",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                //跳转到个人中心页面
                [self quickLogin:snsAccount.accessToken withIcon:snsAccount.iconURL withNickName:snsAccount.userName withChannel:@"3"];
            }});
    }
    else{
        
        NSLog(@"微博已经授权了");
        
        
        //弹出授权处理页面  处理点击登录事件后的block对象

        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            NSLog(@"还未授权%@",response);
            
            //          获取微博用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
                
                NSLog(@"username--%@, uid--%@, token--%@ url--%@ type--微博",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                
                
                //在授权完成后调用获取用户信息的方法
                [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
                    NSLog(@"在微博授权完成后调用获取用户信息的方法 is %@",response.data);
                    
                    [self quickLogin:[response.data objectForKey:@"access_token"] withIcon:[response.data objectForKey:@"profile_image_url"] withNickName:[response.data objectForKey:@"screen_name"] withChannel:@"3"];
                }];

            }});

        }
    

    
}



#pragma mark - 微信快捷登陆
- (IBAction)weixinBtn:(UIButton *)sender {
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    //弹出授权处理页面   处理点击登录事件后的block对象

    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            
            NSLog(@"username--%@, uid--%@, token--%@ url--%@ type--微信",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
//            //跳转到个人中心页面
//            [self quickLogin:snsAccount.accessToken withIcon:snsAccount.iconURL withNickName:snsAccount.userName withChannel:@"1"];
            
            
            
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                NSLog(@"微信快捷登录回调 is %@",response.data);
                
                [self quickLogin:[response.data objectForKey:@"access_token"] withIcon:[response.data objectForKey:@"profile_image_url"] withNickName:[response.data objectForKey:@"screen_name"] withChannel:@"1"];
                
            }];

            
        }
        
        

        
        
    });
    
    
    
 
    
    
}


#pragma mark - qq快捷登陆
- (IBAction)qqBtn:(UIButton *)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
      //弹出授权处理页面
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
            NSLog(@"username--%@, uid--%@, token--%@ url--%@ type--qq",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
//            [self quickLogin:snsAccount.accessToken withIcon:snsAccount.iconURL withNickName:snsAccount.userName withChannel:@"2"]; // qq是2；
//            

            
            
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
                NSLog(@"qq回调 is %@",response.data);
                
                NSLog(@"打印access_token--%@",[response.data objectForKey:@"access_token"]);
                
                [self quickLogin:[response.data objectForKey:@"access_token"] withIcon:[response.data objectForKey:@"profile_image_url"] withNickName:[response.data objectForKey:@"screen_name"] withChannel:@"2"];
            }];

            
            
        }
    
////获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
//        [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
//            NSLog(@"qq回调 is %@",response.data);
//            
//            NSLog(@"打印access_token--%@",[response.data objectForKey:@"access_token"]);
//            
//            [self quickLogin:[response.data objectForKey:@"access_token"] withIcon:[response.data objectForKey:@"profile_image_url"] withNickName:[response.data objectForKey:@"screen_name"] withChannel:@"2"];
//        }];

    
    });
    
    
}



#pragma mark - 微信 微博  QQ都要用到得快捷登陆
- (void)quickLogin:(NSString *)token withIcon:(NSString *)iconURL withNickName:(NSString *)nickName withChannel:(NSString *)channel{
    
    
    
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型

    
    NSString * url= @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";


    // 开始请求
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[@"method"] =@"login";
    dict[@"openid"] =token;
    dict[@"avatar_url"] =iconURL;
    dict[@"nick_name"] =nickName;
    dict[@"channel"] =channel;

    
    //设置参数
    //请求
    [mgr GET:url parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
       // NSLog(@"--请求成功-%@",responseObject);
        
        NSLog(@"--快捷登录成功了-%@",responseObject);

        
        
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
           // NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
          //  [MBProgressHUD showSuccess:str];
            
           //获得用户数据的第一个数组 (花括号就是字典，括号就是数组)
            NSDictionary* dict1 =[[responseObject objectForKey:@"value"] firstObject];
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            [dict setValuesForKeysWithDictionary:dict1];
            
            NSString * mAvatar = dict[@"mAvatar"];
            NSRange range = NSMakeRange(1, 11);
            mAvatar = [mAvatar substringWithRange:range];
            if (![mAvatar isEqualToString:@"user_images"]) {
                dict[@"mAvatar"] = iconURL;
            }else{
    dict[@"mAvatar"] = [NSString stringWithFormat:@"%@%@",SERVER_URL,dict[@"mAvatar"]];
            }
            
            dict[@"mNickName"] = nickName;

            
            //保存用户信息
            [WDInfoTool creatAccountPlist:dict];

            // 登录成功后 发送登录成功的通知
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"successLogin" object:self userInfo:dict];
            
            //成功以后隐藏进度条
           // [MBProgressHUD hideHUDForView:self.view animated:YES];
            //NSString *userID = [[result objectForKey:@"value"] objectForKey:@"resValue"];
            [MBProgressHUD showSuccess:@"登录成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
           // NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            NSString * str = @"用户信息不存在,授权失败,请稍后再试";
            [MBProgressHUD showError:str];
        }
        

        
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        
    }];
}



#pragma mark - 正常的点击登录
- (IBAction)login:(id)sender {
    if (self.username.text ==nil || [self.username.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }
    if (self.passworld.text ==nil || [self.passworld.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    //设置参数
        NSString *phoneNumber = self.username.text;
        // 登录的用户名去除空格
        char * filePathChar = [phoneNumber UTF8String];
        char * s = ReplaceBlank(filePathChar);
        phoneNumber = [NSString stringWithFormat:@"%s",s];
    
    if (phoneNumber.length != 11) {
        [MBProgressHUD showError:@"手机号码长度有误"];
        return;
    }

    if (self.username.text !=nil && self.username.text !=nil) {
        [self.view endEditing:YES];
        //[MBProgressHUD showSuccess:@"登录成功"];
        
        //设置进度条；
        [MBProgressHUD showMessage:@"正在登录" toView:self.view];
        
        // 设置密码
        NSString *password = self.passworld.text;
        
        
        
        // 1.创建一个请求操作管理者
        AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
        // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型

        
        
        // 开始请求
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        param[@"method"] = @"login";
        param[@"account"] = phoneNumber;
        password = [self md5:password];
        password = password.lowercaseString;
        param[@"password"] = password;

        
       // NSDictionary *dic = @{@"method":@"login",@"account":phoneNumber,@"password":password};
        NSString * SERVER_API_URL= @"http://120.25.215.53:8099/api.aspx";
        NSString * SERVER_URL = @"http://120.25.215.53:8099";
        
        //请求
        [mgr GET:SERVER_API_URL parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            // 请求成功的时候调用这个block
            NSLog(@"请求成功---%@", responseObject);
            
          if (![[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"]isEqualToString:@"0"]) {
            //成功以后我就吟进度条
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //NSString *userID = [[result objectForKey:@"value"] objectForKey:@"resValue"];
            NSString *str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
            return ;}
            
            
            //获得用户数据的第一个数组 (花括号就是字典，括号就是数组)
            NSDictionary* dict1 =[[responseObject objectForKey:@"value"] firstObject];
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            [dict setValuesForKeysWithDictionary:dict1];

            NSString * str1 = dict[@"mAvatar"];
            if (![dict[@"mAvatar"] isEqualToString:@""]) {
                str1 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str1];
            }
            dict[@"mAvatar"] = str1;
            
            // 拼接名片
            NSString * str3 = dict[@"mCardUrl"];
            if (![dict[@"mCardUrl"] isEqualToString:@""]) {
                str3 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str3];
            }
            dict[@"mCardUrl"] = str3;


            NSLog(@"打印NSMutableDictionaryNSMutableDictionaryNSMutableDictionary--%@",dict);
            
            
            //保存用户信息
            [WDInfoTool creatAccountPlist:dict];
            

            // 登录成功后 发送登录成功的通知
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"successLogin" object:self userInfo:dict];

            //成功以后隐藏进度条
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //NSString *userID = [[result objectForKey:@"value"] objectForKey:@"resValue"];
            [MBProgressHUD showSuccess:@"登录成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            // 请求失败的时候调用这个block
            NSLog(@"登录失败---%@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"网络连接错误"];

        }];
    }
}

#pragma  mark -去除多余的空格
char* ReplaceBlank(char *s)
{
    //设置两个指针指向数组首元素
     char *p1=s;
     char *p2=s;
    
    while('\0'!=*p1)
    {
        if(' '!=*p2)//如果p2指向不为空格，则将p2指向内容复制给p1指向
            *p1++=*p2++;
        else//如果p2指向为空格，则p2指针向前移动一格。
            p2++;
    }
    
//    NSString * string = [NSString stringWithFormat:@"%s",s];
//    NSLog(@"--用户名-%@",string);
//    
//    
    return s;
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    
    return YES;
}



@end
