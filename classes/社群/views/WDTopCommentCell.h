//
//  WDTopCommentCell.h
//  ZBT
//
//  Created by 投壶 on 15/10/22.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTopicButton.h"

@interface WDTopCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet WDTopicButton *dianzanB;
@property (weak, nonatomic) IBOutlet UILabel *dianzanCount;


@property (copy ,nonatomic) NSString * mIsPraise;// 是否点赞 0否 1是
@property (copy ,nonatomic) NSString * talk_id; // 话题ID


@end
