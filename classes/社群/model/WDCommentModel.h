//
//  WDCommentModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/18.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCommentModel : NSObject
@property (copy ,nonatomic) NSString * mAvatar;                   // 评论者头像
@property (copy ,nonatomic) NSString * mCreateTime;               // 评论时间
@property (copy ,nonatomic) NSString * mIsPraise;                 // 是否点赞 0否 1是
@property (copy ,nonatomic) NSString * mNickName;                     // 评论者名字
@property (copy ,nonatomic) NSString * mTalkCommentID;            // 这条评论的ID
@property (copy ,nonatomic) NSString * mTalkCommentPraiseCount;   // 评论点赞的数量
@property (copy ,nonatomic) NSString * mTalkContent;              // 评论的内容
@property (copy ,nonatomic) NSString * mUserID;                   // 评论者的ID


@end
