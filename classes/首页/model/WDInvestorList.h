//
//  WDInvestorList.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/11.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDInvestorList : NSObject

@property (copy ,nonatomic) NSString * mName;              // 姓名
@property (copy ,nonatomic) NSString * mAvatar;            // 头像URL
@property (copy ,nonatomic) NSString * mID;                // user_id 投资人ID
@property (nonatomic , copy) NSString *mInvestMoney;       // 领头金额

@end
