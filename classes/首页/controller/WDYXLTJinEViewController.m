//
//  WDYXLTJinEViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/17.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDYXLTJinEViewController.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>




@interface WDYXLTJinEViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UITextField *figure;
@property (strong , nonatomic) UIButton * lastBtn;
@property (strong,nonatomic) NSArray * array;
- (IBAction)queding:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *curMoney;  // 当前项目
//当前项目最低起投50万

@property (weak, nonatomic) IBOutlet UILabel *maxFighre;


@end

@implementation WDYXLTJinEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置叉叉
    self.figure.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.figure.placeholder = @"请输入金额";
    // 设置代理
    self.figure.delegate = self;
    // 光标
    if(__IPHONE_8_0 | __IPHONE_7_0){
        self.figure.tintColor=[UIColor blueColor];
    }

    // 获取当前最大投资 和最小投资
    int mMaxInvest = [self.mMaxInvest intValue];  // 最大投资金额
    int mMinInvest = [self.mMinInvest intValue];  // 最小投资金额

    //更给当前的最低起头
    NSString * curMoney = [NSString stringWithFormat:@"当前项目最低起投 %d 万",mMinInvest];
    [self.curMoney setText:curMoney];

    
    //更给当前的最高金额
    NSString * maxFighre = [NSString stringWithFormat:@"当前项目最高投 %d 万",mMaxInvest];
    [self.maxFighre setText:maxFighre];

    
    
    
//    //算出5个的数值
//    
//    int step = (((mMaxInvest)/4)/10)*10;
//    
//    NSString * fig1 = [NSString stringWithFormat:@"%d",mMinInvest];
//    NSString * fig2 = [NSString stringWithFormat:@"%d",step];
//    NSString * fig3 = [NSString stringWithFormat:@"%d",step+step];
//    NSString * fig4 = [NSString stringWithFormat:@"%d",step+step+step];
//    NSString * fig5 = [NSString stringWithFormat:@"%d",mMaxInvest];
//
//    
//    
//    NSArray * array = [NSArray arrayWithObjects:fig1,fig2,fig3,fig4,fig5, nil];
//    self.array = array;
//    
//    int KImageWandH = 240; // 设置
//    if ([[UIScreen mainScreen] bounds].size.width >= 375) {
//        KImageWandH = 320;  //设置
//    }
//    
//    NSInteger arrInitCount  = self.array.count; // 总共有几个
//    
//    CGFloat margin = (self.view.frame.size.width -  KImageWandH ) / 2 ;
//    CGFloat oneX = margin;//第一个表情的X值；
//    CGFloat oneY = 100;//第一给表情的Y值；
//
//    
//    for (int i = 0; i < arrInitCount; ++i) {
//        CGFloat x = oneX;
//        CGFloat y = oneY + i * (10 + 40);
//        
//        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, KImageWandH, 40)];
//        
//        
//        btn.backgroundColor = [UIColor whiteColor];
//        [btn setTitle:array[i] forState:UIControlStateNormal];
//        btn.tag = [array[i] intValue];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.middleView addSubview:btn];
//    }
    
}


-(void)settingViewContent{
    // 1.创建一个请求操作管理者
    
    
    // 获取当前最大投资 和最小投资
    int mMaxInvest = [self.mMaxInvest intValue];  // 最大投资金额
    int mMinInvest = [self.mMinInvest intValue];  // 最小投资金额

    int curInvest = [self.figure.text intValue];
    
    if (curInvest < mMinInvest || curInvest > mMaxInvest) {
        [MBProgressHUD showError:@"输入金额的范围有误"];
        return;
    }
    
    
    
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:window];
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([self.type isEqualToString:@"yixianglingtou"]) {
        params[@"method"] = @"firstInvest";
        NSLog(@"yixianglingtou");
    }else{
        params[@"method"] = @"followInvest";
        NSLog(@"yixianggentou");

    }
    params[@"project_id"] = self.project_id;
    params[@"user_id"] =self.user_id;
    params[@"invest_money"] =self.figure.text;
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
//    NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        
//成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            str = [NSString stringWithFormat:@"%@,意向金额: %@万元",str,self.figure.text];
            [MBProgressHUD showSuccess:str];

            [self.navigationController popViewControllerAnimated:YES];
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


-(void)btnclick:(UIButton *)btn{
    
    [self.view endEditing:YES];
    
    [btn setBackgroundColor:[UIColor colorWithRed:57/255.0 green:165/255.0 blue:134/255.0 alpha:1.0f]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.lastBtn setBackgroundColor:[UIColor whiteColor]];
    [self.lastBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    self.lastBtn = btn;
    self.figure.text = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    
    NSLog(@"btnclick---%ld",(long)btn.tag);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



- (IBAction)queding:(id)sender {
    // 提交
    [self settingViewContent];

}
@end
