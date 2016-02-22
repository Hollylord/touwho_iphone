//
//  customAnnotationView.h
//  ad
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "popUpView.h"

@interface customAnnotationView : MAAnnotationView
@property (strong,nonatomic) popUpView *popView;
@property (copy, nonatomic)  NSString *mTitle; //活动标题
@property (copy, nonatomic)  NSString *mTime;  // 活动时间
@property (copy, nonatomic)  NSString *mAddress;  // 活动地址


@end
