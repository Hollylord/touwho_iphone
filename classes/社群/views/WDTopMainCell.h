//
//  WDTopMainCell.h
//  ZBT
//
//  Created by 投壶 on 15/10/22.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTopicButton.h"

@interface WDTopMainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet WDTopicButton *dianzanB;      // 点赞按钮
@property (weak, nonatomic) IBOutlet UILabel *dianzanCount;  // 点赞数量
@property (weak, nonatomic) IBOutlet WDTopicButton *commentB;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;  // 评论数量


@property (copy ,nonatomic) NSString * mIsPraise;// 是否点赞 0否 1是
@property (copy ,nonatomic) NSString * talk_id; // 话题ID





@end
