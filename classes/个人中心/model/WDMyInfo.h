//
//  WDMyInfo.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/3.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDMyInfo : NSObject
@property (copy ,nonatomic) NSString * mAccount;       // 用户账号
@property (nonatomic , copy) NSString *mAge;           // 年龄
@property (copy ,nonatomic) NSString * mAvatar;        // 用户头像URL
@property (nonatomic , copy) NSString *mCardUrl;       // 名片图像的URL
@property (nonatomic , copy) NSString *mDes;             //投资理念
@property (nonatomic , copy) NSString *mFav;            // 风险偏好
@property (nonatomic , copy) NSString *mFavIndustry;    // 感兴趣行业
@property (copy ,nonatomic) NSString * mEmail;         //用户邮箱
@property (copy ,nonatomic) NSString * mID;            // 用户ID
@property (copy ,nonatomic) NSString * mIDCardCode;     //用户身份证号码
@property (nonatomic , copy) NSString *mIndustry;        // 所属于行业
@property (copy ,nonatomic) NSString * mIntro;          //用户简介
@property (copy ,nonatomic) NSString * mIsFirstInvestor;//是否领头人  1是 0不是
@property (copy ,nonatomic) NSString * mIsInvestor;     //是否投资人  1是 0不是
@property (copy ,nonatomic) NSString * mName;          //用户姓名
@property (copy ,nonatomic) NSString * mNickName;      //用户昵称
@property (copy ,nonatomic) NSString * mPhone;            //用户手机
@property (nonatomic , copy) NSString *mQQ;             //qq
@property (nonatomic , copy) NSString *mWeiXin;         //微信
@property (copy ,nonatomic) NSString * mSex;           //用户性别
@property (copy ,nonatomic) NSString * mType;           //保留
@property (nonatomic , copy) NSString *resCode;         // 状态 0代表成功；
@end
