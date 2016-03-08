//
//  newsContent.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/2.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <MJExtension.h>

@interface newsContent : NSObject

//小图
@property (copy,nonatomic) NSString *mSmallImageUrl; //小图
@property (copy,nonatomic) NSString *mTitle;  // 标题
@property (copy,nonatomic) NSString *mCreateTime;  // 时间
@property (copy,nonatomic) NSString *mSrc; // 来源
@property (copy,nonatomic) NSString *mDestrible; //内容
@property (copy,nonatomic) NSString *mID;   // 新闻ID
@property (nonatomic , copy) NSString *mReadCount; //阅读数量
@property (nonatomic , copy) NSString *mNewsWeixinUrl;


@end
