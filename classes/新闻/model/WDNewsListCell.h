//
//  WDNewsListCell.h
//  ZBT
//
//  Created by 投壶 on 15/9/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WDNewsListCell : UITableViewCell


@property (weak,nonatomic) IBOutlet UIImage * icon;
@property (weak,nonatomic) IBOutlet UILabel * time;
@property (weak,nonatomic) IBOutlet UILabel * text;
@property (weak,nonatomic) IBOutlet UILabel * detailText;

@end
