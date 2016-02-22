//
//  WDShowProjectDetail.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/10.
//  Copyright © 2015年 投壶. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "WDInvestorList.h"

@interface WDShowProjectDetail : NSObject
//@property (copy ,nonatomic) WDInvestorList * mFirstInvestor;       // 领头人列表
//@property (copy ,nonatomic) WDInvestorList * mFollowInvestor;      // 跟头人列表
//@property (copy ,nonatomic) WDInvestorList * mLeaderInvestor;      // 发起人列表
@property (copy ,nonatomic) NSString * mFollowStatus;              // 关注状态 0未关注 1是已关注
@property (copy ,nonatomic) NSString * mLeaderID;                  // 发起人ID
@property (copy ,nonatomic) NSString * mQRUrl;                     // 二维码url
@property (copy ,nonatomic) NSString * mScheme;                    // 众筹方案
@property (copy ,nonatomic) NSString * mSuggest;                   // 项目建议
@property (copy ,nonatomic) NSString * mSummary;                   // 项目摘要
@property (copy ,nonatomic) NSString * mVideo;                     // 项目路演视频
@property (copy ,nonatomic) NSString * resCode;                    // -1 表示没有数据 0 是成功
@property (copy ,nonatomic) NSString * mMaxInvest;                 // 最大的投资金额
@property (copy ,nonatomic) NSString * mMinInvest;                 // 最小的投资金额
@property (copy ,nonatomic) NSString * mProjectUrl;                 // 分享项目的url;




@end
