//
//  WDGroupModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/17.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDGroupModel : NSObject
@property (copy ,nonatomic) NSString * mCreateTime;     // 创建时间
@property (copy ,nonatomic) NSString * mDestrible;      // 小组简介
@property (copy ,nonatomic) NSString * mGroupLeader;    // 小组组长
@property (copy ,nonatomic) NSString * mID;             // 小组ID
@property (copy ,nonatomic) NSString * mIsHot;          // 是否热门小组
@property (copy ,nonatomic) NSString * mIsInGroup;      // 是否在小组里
@property (copy ,nonatomic) NSString * mLogo;           // 小组logo
@property (copy ,nonatomic) NSString * mMemberCount;    // 小组成员数量
@property (copy ,nonatomic) NSString * mName;           // 小组名称
@property (copy ,nonatomic) NSString * mOrder;          // 小组顺序
@property (copy ,nonatomic) NSString * mStatus;         // 小组状态

@end
