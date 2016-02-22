//
//  newsDetailContent.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/2.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface newsDetailContent : NSObject
@property (copy ,nonatomic) NSString * mBottomImageUrl; // 底部图片
@property (copy ,nonatomic) NSString * mLargeImageUrl;  // 顶部图片
@property (copy ,nonatomic) NSString * mContent;        // 内容
@property (copy ,nonatomic) NSString * mIsPraise;       // 点赞
@property (copy ,nonatomic) NSString * resCode;         // 是否登录成功 0表示成功；
@property (nonatomic ,copy) NSString * mPraiseCount;    // 点赞数量；

@end
