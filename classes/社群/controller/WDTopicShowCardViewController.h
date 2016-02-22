//
//  WDTopicShowCardViewController.h
//  ZBT
//
//  Created by 投壶 on 15/9/22.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTopicDetailModel.h" // 楼主的内容

@interface WDTopicShowCardViewController : UITableViewController
//楼主的内容
@property (strong, nonatomic) WDTopicDetailModel * topicDetail;

@end
