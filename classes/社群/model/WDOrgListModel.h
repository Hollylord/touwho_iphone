//
//  WDOrgListModel.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/16.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDOrgListModel : NSObject
@property (copy ,nonatomic) NSString * mCreateTime;  // 机构创建时间
@property (copy ,nonatomic) NSString * mDestrible;   // 机构简介
@property (copy ,nonatomic) NSString * mID;          // 机构ID
@property (copy ,nonatomic) NSString * mLinkUrl;     // 官网地址
@property (copy ,nonatomic) NSString * mLogo;        // 机构LOGO
@property (copy ,nonatomic) NSString * mName;        // 机构名称
@property (copy ,nonatomic) NSString * mOrder;       // 机构顺序
@property (copy ,nonatomic) NSString * mShortName;   // 机构缩写
@end
