//
//  WDLoginTopTableViewCell.h
//  ZBT
//
//  Created by 投壶 on 15/9/17.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDLoginTopTableViewCellDelegate <NSObject>

@optional
-(void)clickIconBtn;
-(void)loginBtn;
@end


@interface WDLoginTopTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *Iconbtn;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak,nonatomic)id<WDLoginTopTableViewCellDelegate> delegate;

@end
