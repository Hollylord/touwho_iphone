//
//  WDnews.h
//  UIScrollView-无限循环
//
//  Created by 222ying on 15/7/26.
//  Copyright (c) 2015年 222ying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDnews : NSObject
//@property (nonatomic , copy) NSString *title;
@property (nonatomic , copy) NSString *mImageUrl; // URl
@property (copy ,nonatomic) NSString * mID;   //轮播图ID
@property (copy ,nonatomic) NSString * mOrder; 
@property (copy ,nonatomic) NSString * mTargetUrl; // 跳转的URl
@end
