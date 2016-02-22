//
//  WDMsgListModel.m
//  touwhoIphone
//
//  Created by 投壶 on 15/11/26.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import "WDMsgListModel.h"
#import <AFNetworking.h>
#import <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>


@implementation WDMsgListModel


-(void)setClientId:(NSString *)clientId{
    _clientId = clientId;
    
    // 请求 发送人的ID;   把名字和图片都设置了;
    //[self upload:self.clientId];
    
    
    
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getMyInfo";
    params[@"user_id"] = clientId;//
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        
        
        //获得用户数据的第一个数组 (花括号就是字典，括号就是数组)
        NSDictionary * dic  = [[responseObject objectForKey:@"value"] firstObject];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        // 判断是否为默认图片
        NSString * str1 = dict[@"mAvatar"];
        if (![dict[@"mAvatar"] isEqualToString:@""]) {
            str1 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str1];
        }
        dict[@"mAvatar"] = str1;
        
        // 设置图片的地址；
        self.image = dict[@"mAvatar"];
        
        
        
       // NSLog(@"_image_image_image_image_image_image--%@",dict[@"mAvatar"]);
        
        // 设置名字
        NSString * proname = [NSString stringWithFormat:@"%@",dict[@"mAccount"]];
        if (![dict[@"mNickName"] isEqualToString:@""]) {
            proname = [NSString stringWithFormat:@"%@",dict[@"mNickName"]];
        }
        self.name = proname;
        
        // 设置好了 发送
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"successSETCell" object:self];
        

        
        
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        
        
    }];

    

}




@end
