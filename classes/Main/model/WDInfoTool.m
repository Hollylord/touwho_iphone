//
//  WDInfoTool.m
//  touwhoIphone
//
//  Created by 222ying on 15/11/17.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import "WDInfoTool.h"

@implementation WDInfoTool


+(void)creatAccountPlist:(NSDictionary *)dict{
   // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    
   //把账号数据存进沙盒；
    [dict writeToFile:path atomically:YES];
}

+(NSDictionary *)getLastAccountPlist{
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];

    //获取当前字典
    NSDictionary * account = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //返回这个字典
    return account;
}

+(NSString *)getLastAccountPlistUserID{
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    
    //获取当前字典
    NSDictionary * account = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString * userID = account[@"mID"];
    
    //返回这个字典
    return userID;
}



+(void)deleteAccountPlist{
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];

    
}

+(NSString *)mIsFirstInvestor{//是否领头人   1是 0不是
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    
    //获取当前字典
    NSDictionary * account = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString * userID = account[@"mIsFirstInvestor"];
    
    //返回这个字典
    return userID;
    

}


+(NSString *)mIsInvestor{//是否投资人   1是 0不是
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    
    //获取当前字典
    NSDictionary * account = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString * userID = account[@"mIsInvestor"];
    
    //返回这个字典
    return userID;
}

+(BOOL)isCanInvestor{
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    
    //获取当前字典
    NSDictionary * account = [NSDictionary dictionaryWithContentsOfFile:path];

    BOOL isCanInvestor = !([account[@"mName"]isEqualToString:@""]||[account[@"mPhone"]isEqualToString:@""]||[account[@"mAge"]isEqualToString:@""]||[account[@"mIndustry"]isEqualToString:@""]||[account[@"mFavIndustry"]isEqualToString:@""]||[account[@"mFav"]isEqualToString:@""]);

    return isCanInvestor;
}


+(NSString *)userName{
    // 沙盒路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [doc stringByAppendingPathComponent:@"account.plist"];
    
    //获取当前字典
    NSDictionary * account = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString * mNickName = account[@"mNickName"];
    
    //返回这个字典
    return mNickName;

}

@end
