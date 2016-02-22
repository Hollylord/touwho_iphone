//
//  WDGroupDetailViewController.h
//  ZBT
//
//  Created by 投壶 on 15/9/21.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDGroupModel.h" // 小组模型


@interface WDGroupDetailViewController : UITableViewController
@property (strong ,nonatomic) WDGroupModel * groupModel;

@end
