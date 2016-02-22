//
//  WDTopicButton.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/19.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDTopicButton : UIButton
@property (copy ,nonatomic) NSString * mid;  // 当前cell所有者的ID
@property (copy ,nonatomic) NSString * target_id;   // 附加的一个ID 一般是在用这个手机的人的ID；
@property (copy ,nonatomic) NSString * talk_id;   // 话题的ID
@property (copy ,nonatomic) NSString * target_icoUrl;   // 对象的头像URL

@end
