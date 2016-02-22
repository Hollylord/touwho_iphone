//
//  lingtourenViewController.m
//  ad
//
//  Created by apple on 15/7/28.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "lingtourenViewController.h"
#import "WDTabBarController.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>

@interface lingtourenViewController ()<UIScrollViewDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *dagouBtn;

- (IBAction)dagou:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextView *comment;// 文本框
@property (weak, nonatomic) IBOutlet UITextView *notes;

- (IBAction)submit:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;



@end

@implementation lingtourenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.comment.delegate = self;
    
//    //更改底部按钮父控件的颜色
//    self.buttonView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    // 设置备注的框；
    self.comment.layer.borderColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0f].CGColor;
    self.comment.layer.borderWidth = 0.5;
    self.comment.layer.cornerRadius= 6;
    self.comment.layer.masksToBounds = YES;
    
    // 光标
    if(__IPHONE_9_0|__IPHONE_8_0 | __IPHONE_7_0){
        self.comment.tintColor=[UIColor blueColor];
    }

    

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 点击按钮
- (IBAction)dagou:(UIButton *)sender {
    self.dagouBtn.selected = !self.dagouBtn.selected;
   
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     self.scrollView.transform =CGAffineTransformMakeTranslation(0,0);
    [self.view endEditing:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tabBar = (WDTabBarController *)self.tabBarController;
    tabBar.tabBar.hidden = YES;
    
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollView.transform =CGAffineTransformMakeTranslation(0,-300);
    }];

    return YES;
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
    params[@"method"] = @"applicateInvestor";
    params[@"user_id"] = mID;//
    params[@"destrible"] = self.comment.text;

    
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



- (IBAction)submit:(id)sender {
    
    if (self.comment.text ==nil || [self.comment.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入申请备注"];
        return;
    }

    if (!self.dagouBtn.selected) {
        [MBProgressHUD showError:@"请勾选协议"];
        return;
    }
    
    [self uploadSet];

    
}
@end
