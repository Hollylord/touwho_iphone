//
//  WDInfoTool.h
//  touwhoIphone
//
//  Created by 222ying on 15/11/17.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDInfoTool : NSObject
+(void)creatAccountPlist:(NSDictionary *)dict;
+(NSDictionary *)getLastAccountPlist;
+(void)deleteAccountPlist;
+(NSString *)getLastAccountPlistUserID;
+(NSString *)mIsFirstInvestor;//是否领头人
+(NSString *)mIsInvestor; //是否投资人
+(BOOL)isCanInvestor;
+(NSString *)userName;

@end
