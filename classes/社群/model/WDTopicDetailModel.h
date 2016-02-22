//
//  WDTopicDetailModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/18.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDTopicDetailModel : NSObject
@property (copy ,nonatomic) NSString * mCreateTime;    // 创建时间
@property (copy ,nonatomic) NSString * mGroupID;       // 所在的小组ID
@property (copy ,nonatomic) NSString * mGroupLogo;     // 所在的小组logo
@property (copy ,nonatomic) NSString * mGroupName;     // 所在的小组名称
@property (copy ,nonatomic) NSString * mID;            // 话题的ID
@property (copy ,nonatomic) NSString * mIsPraise;      // 是否点赞  是否点赞 0否 1是
@property (copy ,nonatomic) NSString * mLogo;          // 话题的头像
@property (copy ,nonatomic) NSString * mPraiseCount;   // 话题点赞的次数
@property (copy ,nonatomic) NSString * mTalkContent;   // 话题内同
@property (copy ,nonatomic) NSString * mTitle;         // 话题标题
@property (copy ,nonatomic) NSString * mUserID;        // 发表话题人的ID
@property (copy ,nonatomic) NSString * mUserName;      // 发表话题人的名字
@property (copy ,nonatomic) NSString * resCode;        // 标记

//@property (copy ,nonatomic) NSString * mTalkComments; // 这个单独写 话题内容列表

@end
