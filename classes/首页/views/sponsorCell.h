//
//  sponsorCell.h
//  touwhoIphone
//
//  Created by 投壶 on 15/11/23.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDInvestorList.h"

@interface sponsorCell : UITableViewCell

@property (strong ,nonatomic)  WDInvestorList * model;
@property (copy ,nonatomic) NSString * type;


@end
