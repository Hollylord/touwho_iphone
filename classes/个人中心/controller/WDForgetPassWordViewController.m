//
//  WDForgetPassWordViewController.m
//  ZBT
//
//  Created by 投壶 on 15/10/21.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDForgetPassWordViewController.h"
#import "UIView+Extension.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>   // MD5



@interface WDForgetPassWordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *checkout;

// 获取验证码；
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
- (IBAction)clickCheckBtn:(id)sender;

// 确定按钮
- (IBAction)sure:(id)sender;


//@property(assign,nonatomic)BOOL selectBtn3;  // 是否勾选

// 验证码倒计时
@property (assign , nonatomic) int second;


@end

@implementation WDForgetPassWordViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置叉叉
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.checkout.clearButtonMode = UITextFieldViewModeWhileEditing;
  
    
    // 设置代理
    self.phoneTF.delegate = self;
    self.passwordTF.delegate = self;
    self.checkout.delegate = self;
    
    // 光标
    if(__IPHONE_8_0 | __IPHONE_7_0){
        self.phoneTF.tintColor=[UIColor blueColor];
        self.passwordTF.tintColor=[UIColor blueColor];
        self.checkout.tintColor=[UIColor blueColor];        
    }
    
    
    UIImageView * registerPhone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerPhone"]];
    registerPhone.width = 30;
    registerPhone.height = 30;
    registerPhone.contentMode = UIViewContentModeCenter; // 让放大镜居中；
    self.phoneTF.leftView = registerPhone;
    self.phoneTF.leftViewMode = UITextFieldViewModeAlways; // 这个一定要设置，因为默认是不显示；
    
    UIImageView * registerPassworld = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerPassworld"]];
    registerPassworld.width = 30;
    registerPassworld.height = 30;
    registerPassworld.contentMode = UIViewContentModeCenter; // 让放大镜居中；
    self.passwordTF.leftView = registerPassworld;
    self.passwordTF.leftViewMode = UITextFieldViewModeAlways; // 这个一定要设置，因为默认是不显示；
    
    
    
    // 键盘的通知
    // 通知中心 在这里；  监听键盘；
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter]; //单例；
    
    // UITextFieldText开始编辑
    [center addObserver:self selector:@selector(textFiedTextBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    // UITextFieldText结束编辑
    [center addObserver:self selector:@selector(textFiedTextDidEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    
//    //
//    
//    mgr = [AFHTTPRequestOperationManager manager];
//    //新增可接受contentType
//    mgr.responseSerializer.acceptableContentTypes= [NSSet setWithObject:@"text/html"];
//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFiedTextBeginEditing:(NSNotification *)noti{
    
    if ([noti.object isEqual:self.checkout]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -100);
        }];
    }
    
}

-(void)textFiedTextDidEditing:(NSNotification *)noti{

    [UIView animateWithDuration:0.25f animations:^{
        self.view.transform =CGAffineTransformMakeTranslation(0, 0);
    }];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}



- (IBAction)clickCheckBtn:(id)sender {
    
    [self.view endEditing:YES];

    
    
    if (self.phoneTF.text.length != 11) {
        [MBProgressHUD showError:@"手机号码长度有误"];
        return ;
    }

    if (self.passwordTF.text == nil || [self.passwordTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    
    //设置参数
    NSString *phoneNumber = self.phoneTF.text;
  //  NSString *password = self.passwordTF.text;
   // NSString *vercode = self.checkout.text;
    
    
   
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在发送" toView:window];

    
    NSString * SERVER_API_URL= @"http://120.25.215.53:8099/api.aspx";
    
    //发送请求
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getVercode_find";
    params[@"phone"] = phoneNumber;

    //请求
    [mgr GET:SERVER_API_URL parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        // 请求成功的时候调用这个block
        NSLog(@"请求成功---%@", responseObject);
        
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showSuccess:str];
            
            // 这里开始发送验证码
            [self receiveCheck];
        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
}





#pragma mark - 开始接收验证码
-(void)receiveCheck{

    //添加一个倒计时的label
    UILabel *label = [[UILabel alloc] initWithFrame:self.checkBtn.bounds];
    [label setText:[NSString stringWithFormat:@"(60)秒后重发"]];
    [label setFont:[UIFont systemFontOfSize:12]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor grayColor]];
    [self.checkBtn addSubview:label];
    [self.checkBtn setEnabled:NO];
    
    //设定倒计时的总时长
    self.second = 60;
    
    //执行倒计时
    [self performSelector:@selector(reflashGetKeyBt:) withObject:[NSNumber numberWithInt:self.second] afterDelay:0];
    
    
}


#pragma mark - 倒计时
- (void)reflashGetKeyBt:(NSNumber *)sec
{
    if ([sec integerValue] == 0)
    {
        [self.checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UILabel *label = [self.checkBtn.subviews lastObject];
        [label removeFromSuperview];
        [self.checkBtn setEnabled:YES];

    }
    else
    {
        [self.checkBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        int i = [sec intValue];
        UILabel *label = [self.checkBtn.subviews lastObject];
        [label setText:[NSString stringWithFormat:@"(%i)秒后重发",i]];
        [self performSelector:@selector(reflashGetKeyBt:) withObject:[NSNumber numberWithInt:i-1] afterDelay:1];
    }
    
}


- (IBAction)sure:(id)sender {
    
    
    [self.view endEditing:YES];

    
    if (self.phoneTF.text == nil || [self.phoneTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }
    if (self.passwordTF.text == nil || [self.passwordTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    if (self.checkout.text == nil || [self.checkout.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入验证码"];
        return;
    }

    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在发送" toView:window];

    
    //设置参数
    NSString *phoneNumber = self.phoneTF.text;
    NSString *password = self.passwordTF.text;
    NSString *vercode = self.checkout.text;
    
    NSString * SERVER_API_URL= @"http://120.25.215.53:8099/api.aspx";
    //发送请求
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"method"] = @"checkVerCode_find";
    params[@"phone"] = phoneNumber;
    password = [self md5:password];
    password = password.lowercaseString;
    params[@"password"] = password;
    params[@"ver_code"] = vercode;


    
    [mgr GET:SERVER_API_URL parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
        
        
        // 请求成功的时候调用这个block
        NSLog(@"请求成功---%@", responseObject);
        
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];

        
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {

            [MBProgressHUD showSuccess:@"修改成功,请重新登录"];
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        //失败 账号不存在
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        //失败 验证码错误
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-2"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }


        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"登录失败---%@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
    }];

}


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

@end
