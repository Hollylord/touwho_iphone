//
//  WDPersonalInfoViewController.h
//  ZBT
//
//  Created by 投壶 on 15/10/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDPersonalInfoViewController : UITableViewController

@property (copy ,nonatomic) NSString * user_id;// 自己的ID
@property (copy ,nonatomic) NSString * target_id; // 别人的ID
@property (copy ,nonatomic) NSString * target_iconUrl; // 别人的touxiang



@end
