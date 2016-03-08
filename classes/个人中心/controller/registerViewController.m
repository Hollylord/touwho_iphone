//
//  registerViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/7.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "registerViewController.h"
#import "UIView+Extension.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import "WDMyInfo.h" //个人信息模型
#import <CommonCrypto/CommonDigest.h>   // MD5
#import "personInformationViewController.h"


@interface registerViewController ()<UITextFieldDelegate>
// 手机号码，密码，验证码，输入邀请人
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *checkout;
@property (weak, nonatomic) IBOutlet UITextField *inviterperson;


@property (weak, nonatomic) IBOutlet UIButton *btn1;   // 投资人
@property (weak, nonatomic) IBOutlet UIButton *btn2;   // 创业者


// 投资人，创业者
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)btn1click:(UIButton *)sender;
- (IBAction)btn2click:(UIButton *)sender;


// 接受验证码
@property (weak, nonatomic) IBOutlet UIButton *getCheckLable;
- (IBAction)clickCheckBtn:(id)sender; // 点击验证码

// 投资人 创业者
@property(assign,nonatomic)BOOL selectBtn1;
@property(assign,nonatomic)BOOL selectBtn2;


// 服务协议
@property (weak, nonatomic) IBOutlet UIButton *selecbtn; // 同意按钮；
@property(assign,nonatomic)BOOL selectBtn3;  // 是否勾选
- (IBAction)btnDG:(UIButton *)sender;        // 同意按钮；



- (IBAction)riskWarnBtn:(UIButton *)sender; // 风险提示
- (IBAction)agreementBtn:(UIButton *)sender;// 服务协议

//注册按钮
- (IBAction)registerBtn:(id)sender;

// 倒计时
// 验证码倒计时
@property (assign , nonatomic) int second;


@end

@implementation registerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置叉叉
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.checkout.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inviterperson.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // 设置代理
    self.phoneTF.delegate = self;
    self.passwordTF.delegate = self;
    self.checkout.delegate = self;
    self.inviterperson.delegate = self;
    
    // 光标
    if(__IPHONE_8_0 | __IPHONE_7_0){
        self.phoneTF.tintColor=[UIColor blueColor];
        self.passwordTF.tintColor=[UIColor blueColor];
        self.checkout.tintColor=[UIColor blueColor];
        self.inviterperson.tintColor=[UIColor blueColor];

    }


    //记录按钮的状态;
    self.selectBtn1 = YES;
    self.selectBtn2 = NO;
    self.selectBtn3 = YES;  //默认已经勾选
    
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

    
    UIImageView * registerName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerName"]];
    registerName.width = 30;
    registerName.height = 30;
    registerName.contentMode = UIViewContentModeCenter; // 让放大镜居中；
    self.inviterperson.leftView = registerName;
    self.inviterperson.leftViewMode = UITextFieldViewModeAlways; // 这个一定要设置，因为默认是不显示；


    
    // 键盘的通知
    // 通知中心 在这里；  监听键盘；
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter]; //单例；
    //// 监听 监听者 ；添加监听者；
    //    [center addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // UITextFieldText开始编辑
    [center addObserver:self selector:@selector(textFiedTextBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    // UITextFieldText结束编辑
    [center addObserver:self selector:@selector(textFiedTextDidEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
//    
//    //
//    mgr = [AFHTTPRequestOperationManager manager];
//    //新增可接受contentType
//    mgr.responseSerializer.acceptableContentTypes= [NSSet setWithObject:@"text/html"];
//    //responseSerializer设定返回的默认都是json,由于已经设置acceptableContentTypes了 所以不要在设置responseSerializer, 否则上面的设置就被覆盖了。
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}


- (IBAction)btn1click:(UIButton *)sender {
    
    if (self.selectBtn1 == YES) return;
        self.selectBtn2 = !self.selectBtn2;
        self.selectBtn1 = !self.selectBtn1;
    
    
    if(self.selectBtn1){
        [self.imageView setImage:[UIImage imageNamed:@"registerL"]];
        [self.btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        
    }else{
        [self.imageView setImage:[UIImage imageNamed:@"registerR"]];
        [self.btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
}

- (IBAction)btn2click:(UIButton *)sender {
    
    if (self.selectBtn2 == YES) return;

        self.selectBtn2 = !self.selectBtn2;
        self.selectBtn1 = !self.selectBtn1;
    if(self.selectBtn2){
        [self.imageView setImage:[UIImage imageNamed:@"registerR"]];
        [self.btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    }else{
        [self.imageView setImage:[UIImage imageNamed:@"registerL"]];
        [self.btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    if (self.selectBtn1) {
        NSLog(@"投资人");
    }
    
    if (self.selectBtn2) {
        NSLog(@"创业者");
    }

    if (self.selectBtn3) {
        NSLog(@"打钩");
    }else {
        NSLog(@"未打钩");
    }

    
}


-(void)textFiedTextBeginEditing:(NSNotification *)noti{
    
    if ([noti.object isEqual:self.checkout]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -200);
        }];
    }
    if ([noti.object isEqual:self.inviterperson]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -200);
        }];
    }
    
}

-(void)textFiedTextDidEditing:(NSNotification *)noti{
    [UIView animateWithDuration:0.25f animations:^{
        self.view.transform =CGAffineTransformMakeTranslation(0,0);
    }];
}


- (IBAction)btnDG:(UIButton *)sender {
    
    self.selectBtn3 = !self.selectBtn3;
    if(self.selectBtn3){
    [self.selecbtn setBackgroundImage:[UIImage imageNamed:@"dagouSelected"] forState:UIControlStateNormal];
    }else{
    [self.selecbtn setBackgroundImage:[UIImage imageNamed:@"dagouNormal"] forState:UIControlStateNormal];
    }

}

- (IBAction)riskWarnBtn:(UIButton *)sender {
    
}

- (IBAction)agreementBtn:(UIButton *)sender {
    
}

#pragma mark 点击注册
- (IBAction)registerBtn:(id)sender {
    
    
    
//    @property (weak, nonatomic) IBOutlet UITextField *phoneTF;
//    @property (weak, nonatomic) IBOutlet UITextField *passwordTF;
//    @property (weak, nonatomic) IBOutlet UITextField *checkout;
//    @property (weak, nonatomic) IBOutlet UITextField *inviterperson;
    
//    
    [self.view endEditing:YES];

    if (!self.selectBtn3) {
        [MBProgressHUD showError:@"请勾选并同意"];
        return;
    }
    
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
    
    

    NSString * url= @"http://120.25.215.53:8099/api.aspx";
    
    //设置参数
    NSString *phoneNumber = self.phoneTF.text;
    NSString *password = self.passwordTF.text;
    NSString *vercode = self.checkout.text;
    NSString *invitator = self.inviterperson.text;
    NSString *userType;
    if (self.selectBtn3) { userType = @"1";}else {userType = @"2";}
    
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"checkVerCode";
    
    params[@"phone"] = phoneNumber;
    password = [self md5:password];
    password = password.lowercaseString;
    params[@"password"] = password;
    params[@"ver_code"] = vercode;
    params[@"user_type"] = userType;
    params[@"invester"] = invitator;

    
    //请求
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        // 请求成功的时候调用这个block
        NSLog(@"请求成功---%@", responseObject);
        
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        
//
//        //验证成功
//        if ([[[responseObject objectForKey:@"value"] objectForKey:@"resCode"] isEqualToString:@"0"]){
//            NSString *userID = [[responseObject objectForKey:@"value"] objectForKey:@"resValue"];
//            
//            //保存用户信息
//            NSDictionary *dict = @{@"userName":phoneNumber,@"userID":userID};
//            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//            [userDefault setObject:dict forKey:@"user"];
//            [userDefault synchronize];
//           
//        }
//
        
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
            [MBProgressHUD showSuccess:@"注册成功"];
            NSDictionary * dict = [[responseObject objectForKey:@"value"] firstObject];
            WDMyInfo * myInfo = [WDMyInfo objectWithKeyValues:dict];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            personInformationViewController *controller = [sb instantiateViewControllerWithIdentifier:@"WDpersonInformationViewController"];
            [self presentViewController:controller animated:YES completion:^{
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            
            
            //成功后就退出这个注册页面；返回到登陆页面
//            [self.navigationController popViewControllerAnimated:YES];
        }
        
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        //失败2 验证码不正确";
        
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
- (IBAction)clickCheckBtn:(id)sender {
    
    
    [self.view endEditing:YES];
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在发送" toView:window];

    
    //设定参数
    //如果不是11位手机号
    if (self.phoneTF.text.length != 11) {
//        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self animated:YES];
//        hub.mode = MBProgressHUDModeText;
//        hub.labelText = @"手机号不正确";
//        [hub hide:YES afterDelay:0.5];
        [MBProgressHUD showError:@"手机号码长度有误"];
        return ;
    }
    
    NSString * SERVER_API_URL= @"http://120.25.215.53:8099/api.aspx";
    NSString *phoneNumber = self.phoneTF.text;
    //发送请求
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getVercode";
    params[@"phone"] = phoneNumber;
    NSString *userType;
    if (self.selectBtn3) { userType = @"1";}else {userType = @"2";}
    
    NSLog(@"user--%@",userType);
    
    params[@"user_type"] = userType;

    

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
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败%@",error);
        
        
    }];

}


#pragma mark - 开始接收验证码
-(void)receiveCheck{
    

    //添加一个倒计时的label
    UILabel *label = [[UILabel alloc] initWithFrame:self.getCheckLable.bounds];
    [label setText:[NSString stringWithFormat:@"(60)秒后重发"]];
    [label setFont:[UIFont systemFontOfSize:12]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor grayColor]];
    [self.getCheckLable addSubview:label];
    [self.getCheckLable setEnabled:NO];

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
        [self.getCheckLable setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.getCheckLable.subviews.lastObject removeFromSuperview];
        [self.getCheckLable setEnabled:YES];

    }
    else
    {
        [self.getCheckLable setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        int i = [sec intValue];
        UILabel *label = [self.getCheckLable.subviews lastObject];
        [label setText:[NSString stringWithFormat:@"(%i)秒后重发",i]];
        [self performSelector:@selector(reflashGetKeyBt:) withObject:[NSNumber numberWithInt:i-1] afterDelay:1];
    }
    
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
