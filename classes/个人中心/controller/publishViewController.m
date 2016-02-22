//
//  publishViewController.m
//  ad
//
//  Created by apple on 15/7/28.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "publishViewController.h"
#import "WDPickerView.h"
#import "WDTabBarController.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>


@interface publishViewController ()<UITextFieldDelegate,UITextViewDelegate,WDPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *company;    // 公司名字
@property (weak, nonatomic) IBOutlet UITextField *industry;   // 所属行业
@property (weak, nonatomic) IBOutlet UITextField *projectName;  // 项目名称
@property (weak, nonatomic) IBOutlet UITextField *figure;   // 融资金额
@property (weak, nonatomic) IBOutlet UITextField *projectLocation; // 项目地点；
@property (weak, nonatomic) IBOutlet UITextField *projectPhases;  // 项目阶段
@property (weak, nonatomic) IBOutlet UITextView *projectIntro; // 项目简介

@property (weak, nonatomic) IBOutlet UIView *grayview;





/**
 *  <#Description#>
 */

@property (strong, nonatomic) NSString *areaValue;
@property (strong, nonatomic) NSString *cityValue;
@property (strong, nonatomic) NSString *industryValue;
@property (strong, nonatomic) WDPickerView *locatePicker;

-(void)cancelLocatePicker;



/**
 *  <#Description#>
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLConstranit; //34
@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameRConstraint; //45



- (IBAction)submit:(id)sender;


@end

@implementation publishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置最外面的view的背景
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
//    //更改底部按钮父控件的颜色
//    self.buttonView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    
    // 设置代理
    self.company.delegate = self;
    self.industry.delegate =self;
    self.projectName.delegate = self;
    self.figure.delegate =self;
    self.projectLocation.delegate = self;
    self.projectPhases.delegate = self;
    
    
    // 光标
    if(__IPHONE_8_0 | __IPHONE_7_0){
        self.company.tintColor=[UIColor blueColor];
        self.projectName.tintColor=[UIColor blueColor];
        self.figure.tintColor=[UIColor blueColor];
        self.projectIntro.tintColor=[UIColor blueColor];

    }

    
    // 设置框框的叉叉；
    self.company.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.industry.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.projectName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.figure.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.projectLocation.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.projectPhases.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //监听回车；
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    
    // UITextFieldText开始编辑
    [center addObserver:self selector:@selector(textFiedTextBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    // UITextFieldText结束编辑
    [center addObserver:self selector:@selector(textFiedTextDidEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    // 设置textView；
    self.projectIntro.layer.borderColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0f].CGColor;

    self.projectIntro.layer.borderWidth = 0.5;
    self.projectIntro.layer.cornerRadius= 6;
    self.projectIntro.layer.masksToBounds = YES;
    
    self.projectIntro.delegate = self;
    
    //  适配5屏幕
    if([[UIScreen mainScreen] bounds].size.width <375){
        self.nameLConstranit.constant = 8;
        self.nameRConstraint.constant = 8;
        [self.company layoutIfNeeded];
        [self.name layoutIfNeeded];
        
    }

    
}

-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tabBar = (WDTabBarController *)self.tabBarController;
    tabBar.tabBar.hidden = YES;
    
    
}



-(void)setAreaValue:(NSString *)areaValue
{
    if (![_areaValue isEqualToString:areaValue]) {
        self.projectLocation.text = areaValue;
    }
}

-(void)setCityValue:(NSString *)cityValue
{
    if (![_cityValue isEqualToString:cityValue]) {
        self.projectPhases.text = cityValue;
    }
}

-(void)setIndustryValue:(NSString *)industryValue{
    if (![_industryValue isEqualToString:industryValue]) {
        self.industry.text = industryValue;
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25f animations:^{
        self.grayview.transform =CGAffineTransformMakeTranslation(0,0);
    }];
    
    
    [self cancelLocatePicker];


}

#pragma mark  - send TextField的代理方法; 点击右下角的send按钮、、
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25f animations:^{
        self.grayview.transform =CGAffineTransformMakeTranslation(0,0);
    }];
    
    return YES;  // 直接给一个yes;
}



// 监听输入框
#pragma mark - textFied 通知
-(void)textFiedTextBeginEditing:(NSNotification *)noti{
        [self cancelLocatePicker];
    
    if ([noti.object isEqual:self.figure]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.grayview.transform =CGAffineTransformMakeTranslation(0, -50);
        }];
    }
    
}


-(void)textFiedTextDidEditing:(NSNotification *)noti{
    
    if ([noti.object isEqual:self.projectPhases]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.grayview.transform =CGAffineTransformMakeTranslation(0, -80);
        }];
        
        return;
    }
    
    
    [UIView animateWithDuration:0.25f animations:^{
        self.grayview.transform =CGAffineTransformMakeTranslation(0,0);
    }];
}


#pragma mark - textView 代理；

////将要开始编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    [self cancelLocatePicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.grayview.transform =CGAffineTransformMakeTranslation(0, -250);
    }];

    return YES;
}

//将要结束编辑
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [UIView animateWithDuration:0.25f animations:^{
        self.grayview.transform =CGAffineTransformMakeTranslation(0,0);
    }];

    return YES;
}


#pragma mark - HZAreaPicker delegate
- (void)pickerDidChaneStatus:(WDPickerView *)picker;
{
    if (picker.pickerStyle == WDPickerStyle3shenghuidiquchengshi) {
        self.areaValue = [NSString stringWithFormat:@"%@ %@ %@", picker.locate.state, picker.locate.city, picker.locate.district];
    }

    if(picker.pickerStyle == WDPickerStyle2)
    {
        self.cityValue = [NSString stringWithFormat:@"%@ %@", picker.locate.state, picker.locate.city];
    }
    
    
    if(picker.pickerStyle == WDPickerStyle1projectPhase)
    {
        self.cityValue = [NSString stringWithFormat:@"%@ ", picker.locate.projectPhase];
    }

    
    
    if(picker.pickerStyle == WDPickerStyle3ruzhudanwei)
    {
        self.industryValue = [NSString stringWithFormat:@"%@ %@ %@", picker.locate.industry1, picker.locate.industry2, picker.locate.industry3];
    }

    

}


-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}


#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.projectLocation]) {
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.25f animations:^{
            self.grayview.transform =CGAffineTransformMakeTranslation(0, -80);
        }];

        // 这里初始化，这里开始执行调用；// 把代理传进去
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle3shenghuidiquchengshi delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];// 这里显示
        return NO;  // 这样就不会弹出来键盘来了


    }
    /**
     *  WDPickerView *locatePicker  locatePicker有这些方法；showInView
     */
    
    
    if ([textField isEqual:self.projectPhases]){
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.25f animations:^{
            self.grayview.transform =CGAffineTransformMakeTranslation(0, -100);
        }];

        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle1projectPhase delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];
        return NO;  // 这样就不会弹出来键盘来了

    }
    
    
    if ([textField isEqual:self.industry]){
        [self cancelLocatePicker];
        [self.view endEditing:YES];        
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle3ruzhudanwei delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];
        return NO;  // 这样就不会弹出来键盘来了
        
    }
    return YES;  // 如果不是上面所选的 那么就弹出键盘；
}


- (IBAction)submit:(id)sender {
    
    if (self.company.text ==nil || [self.company.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入公司名字"];
        return;
    }
    if (self.industry.text ==nil || [self.industry.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请选择行业"];
        return;
    }
    if (self.projectName.text ==nil || [self.projectName.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入项目名称"];
        return;
    }
    if (self.figure.text ==nil || [self.figure.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入融资金额"];
        return;
    }
    if (self.projectLocation.text ==nil || [self.projectLocation.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入项目地点"];
        return;
    }

    if (self.projectPhases.text ==nil || [self.projectPhases.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入项目阶段"];
        return;
    }
    
    if (self.projectIntro.text ==nil || [self.projectIntro.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"输入项目简介"];
        return;
    }


    
    [self uploadSet];

}




#pragma mark -上传
-(void)uploadSet{
    
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 声明：不要对服务器返回的数据进行解析，直接返回data即可
    // 如果是文件下载，肯定是用这个
    // responseObject的类型是NSData
    // mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString * mID = self.mID;
    params[@"method"] = @"addProject";
    params[@"user_id"] = mID; //用户ID
    params[@"company"] = self.company.text; // 公司名字
    params[@"industry_name"] = self.industry.text; // 所属行业
    params[@"project_name"] = self.projectName.text; // 项目名称
    params[@"goal_money"] = self.figure.text; // 融资金额
    params[@"province"] = self.projectLocation.text; // 项目位置
    params[@"invest_step"] = self.projectPhases.text; // 融资阶段
    params[@"destrible"] = self.projectIntro.text; // 项目简介

    
    NSLog(@"请求之前 弄一下看一下这--%@",params);
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功---%@", responseObject);
        //缺少必要参数；
        
        NSString * resCode = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"];
        if ([resCode isEqualToString:@"0"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showSuccess:str];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败==%@",error);
        
        
    }];
    
    
}


@end
