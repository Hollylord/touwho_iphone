//
//  WDTopMainCell.m
//  ZBT
//
//  Created by 投壶 on 15/10/22.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDTopMainCell.h"
#import "WDInfoTool.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>

@interface WDTopMainCell ()
@property (assign, nonatomic) BOOL iSdianzan;
@property (assign, nonatomic) BOOL iSYijingdianzan;


@end


@implementation WDTopMainCell



-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    NSLog(@"--self.mIsPraise-%@----talk_id-%@-----",self.mIsPraise,self.talk_id);

    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSLog(@"--self.mIsPraise-%@----talk_id-%@-----",self.mIsPraise,self.talk_id);
        
        
        if ([self.mIsPraise isEqualToString:@"0"]) { // 0未点赞 1是点赞
            self.iSdianzan = NO;
        }else{
            self.iSdianzan = YES;
        }
    }
    return self;
}

- (IBAction)dianznaBtn:(id)sender {
    
    

    
    NSLog(@"--self.mIsPraise-%@----talk_id-%@-----",self.mIsPraise,self.talk_id);
   // NSLog(@"--iSYijingdianzan--%@",self.iSYijingdianzan);

    
    if ([self.mIsPraise isEqualToString:@"0"]&&self.iSYijingdianzan!=YES) { // 0未点赞 1是点赞
         NSLog(@"--iSYijingiSYijingdianzandianziSYijingdianzanan--");
        self.iSdianzan = NO;
    }
    
    if ([self.mIsPraise isEqualToString:@"1"]&&self.iSYijingdianzan!=YES) // 0未点赞 1是点赞
    {
        NSLog(@"--iSYijingiSYijingdianzandianziSYijingdianzanan--");
        self.iSdianzan = YES;
    }

    
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

 
    
    if (self.iSdianzan == NO) {
        [self dianzan];
    }
    
    if (self.iSdianzan == YES)
    {
        [self quxiaodianzhan];

    }

    
}


- (IBAction)commentA:(id)sender {
    
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDCommentViewController"];
//    [self.navigationController pushViewController:controller animated:YES];

    
}

#pragma mark - 点赞
-(void)dianzan{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"followTalk";
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    params[@"user_id"] = userID;
    params[@"talk_id"] = self.talk_id;

    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    //NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功-dianzan-%@", responseObject);
         
      //成功
      if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
          NSString * str = @"点赞成功";
          [MBProgressHUD showSuccess:str];

          
          
          NSString * text = self.dianzanCount.text;
          int intString = [text intValue];
          self.iSdianzan = YES;
          [self.dianzanB setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
          intString++;
          self.dianzanCount.text = [NSString stringWithFormat:@"%d",intString];

          self.iSYijingdianzan = YES; // 说明已经点过了 那就不再次对iSdianzan初始化了
          
      }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"点赞失败";
             [MBProgressHUD showError:str];
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    

    
    
    
    
}


#pragma mark - 取消点赞
-(void)quxiaodianzhan{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"cancelFollowTalk";
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    params[@"user_id"] = userID;
    params[@"talk_id"] = self.talk_id;
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    //NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功-dianzan-%@", responseObject);
         
         //成功
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
             NSString * str = @"取消点赞成功";
             [MBProgressHUD showSuccess:str];
             
             
             NSString * text = self.dianzanCount.text;
             int intString = [text intValue];

             self.iSdianzan = NO;
             [self.dianzanB setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
             intString--;
             self.dianzanCount.text = [NSString stringWithFormat:@"%d",intString];
             
             self.iSYijingdianzan = YES; // 说明已经点过了 那就不再次对iSdianzan初始化了
             
             
         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"取消点赞失败";
             [MBProgressHUD showError:str];
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    

    
    
}


@end
