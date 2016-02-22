//
//  WDVidoeListModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/12.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDActivityListModel : NSObject
@property (copy ,nonatomic) NSString * mAddress;       //活动地址
@property (copy ,nonatomic) NSString * mID;            //活动ID
@property (copy ,nonatomic) NSString * mSmallImageUrl; //活动图片URl
@property (copy ,nonatomic) NSString * mStatus;        //活动状态   进行中是1  未开始0  已经结束是2
@property (copy ,nonatomic) NSString * mTime;          //活动时间
@property (copy ,nonatomic) NSString * mTitle;         //活动标题

@end
