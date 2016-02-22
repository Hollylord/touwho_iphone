//
//  WDCommentViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/22.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDCommentViewController.h"
#import "MBProgressHUD+MJ.h"
#import "WDInfoTool.h"  //获取沙盒的登录信息
#import <AFNetworking.h>

@interface WDCommentViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentTF;

- (IBAction)sureBtn:(UIBarButtonItem *)sender;


@end

@implementation WDCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    // 设置叉叉
//    self.commentTF.clearButtonMode = UITextFieldViewModeWhileEditing;
//    // 设置代理
    
     self.commentTF.delegate = self;
    // 光标
    if(__IPHONE_8_0 | __IPHONE_7_0){
        self.commentTF.tintColor=[UIColor blueColor];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (IBAction)sureBtn:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    
    if (self.commentTF.text ==nil || [self.commentTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入评论内容"];
        return;
    }

    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSString * topicID = self.topicID;
    
    
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    // 首先要获得最上面的窗口
    // UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:self.view];
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"addOneTalk";
    params[@"user_id"] = userID;
    params[@"talk_id"] = topicID;
    params[@"content"] = self.commentTF.text;

    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功-getAllGroupContent-%@", responseObject);
         //成功以后我就进度条
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         //成功
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
             NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             [MBProgressHUD showSuccess:str];
            
             
             // 登录成功后 发送登录成功的通知
             NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:@"successComment" object:self];
             
             //[MBProgressHUD showSuccess:@"评论成功"];
             
             [self.navigationController popViewControllerAnimated:YES];

         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             [MBProgressHUD showError:str];
         }
                  
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];

    
    

    


    

}
@end
