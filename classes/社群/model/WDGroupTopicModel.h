//
//  WDGroupTopicModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/17.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDGroupTopicModel : NSObject
@property (copy ,nonatomic) NSString * mCommentCount;  // 评论数量
@property (copy ,nonatomic) NSString * mCreateTime;    // 创建时间
@property (copy ,nonatomic) NSString * mDestrible;     // 内容
@property (copy ,nonatomic) NSString * mID;            // 话题ID
@property (copy ,nonatomic) NSString * mIsHot;         // 热门
@property (copy ,nonatomic) NSString * mLogo;          // 话题logo
@property (copy ,nonatomic) NSString * mShortTitle;    // 话题名字
@property (copy ,nonatomic) NSString * mTitle;         // 话题名字
@property (copy ,nonatomic) NSString * mGroupName;     //所在小组

@end
