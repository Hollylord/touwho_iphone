//
//  WDShowProject.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/10.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDShowProject : NSObject
@property (copy ,nonatomic) NSString * mCompanyName;       // 公司名称
@property (copy ,nonatomic) NSString * mCurMoney;          // 当前融资金额
@property (copy ,nonatomic) NSString * mDestrible;         // 项目简介
@property (copy ,nonatomic) NSString * mFollowStatus;      // 关注状态0未关注1已关注 --
@property (copy ,nonatomic) NSString * mFullImageUrl;      // 项目大图url
@property (copy ,nonatomic) NSString * mGoalMoney;         // 目标金额
@property (copy ,nonatomic) NSString * mID;                // 项目ID
@property (copy ,nonatomic) NSString * mIndustryName;      // 行业名称
@property (copy ,nonatomic) NSString * mInvestStep;        // 融资阶段
@property (copy ,nonatomic) NSString * mProvince;          // 项目位置
@property (copy ,nonatomic) NSString * mSmallImageUrl;     // 项目缩略图url
@property (copy ,nonatomic) NSString * mStatus;            // 项目状态 --
@property (copy ,nonatomic) NSString * mTitle;             // 项目名称
@property (copy ,nonatomic) NSString * mType;              // 项目类型  1就是国内 4是海外；

@end
