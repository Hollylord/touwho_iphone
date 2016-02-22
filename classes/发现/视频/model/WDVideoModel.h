//
//  WDVideoModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/13.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDVideoModel : NSObject
@property (copy ,nonatomic) NSString * mCreateTime; // 创建时间
@property (copy ,nonatomic) NSString * mID;         // 项目ID
@property (copy ,nonatomic) NSString * mName;       // 视频名字
@property (copy ,nonatomic) NSString * mOrder;      // 视频顺序
@property (copy ,nonatomic) NSString * mStatus;     // 状态
@property (copy ,nonatomic) NSString * mVID;        // IOS专用视频ID
@property (copy ,nonatomic) NSString * mVideoUrl;   // 视频URL
@end
