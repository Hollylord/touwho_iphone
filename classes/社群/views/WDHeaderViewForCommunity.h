//
//  WDHeaderViewForCommunity.h
//  ZBT
//
//  Created by 投壶 on 15/9/15.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDHeaderViewForCommunityDelegate <NSObject>

@optional
-(void)WDHeaderViewForCommunitySelsctedNoti;
-(void)WDHeaderViewForCommunitySelsctedMessage;
@end


@interface WDHeaderViewForCommunity : UIView




@property (weak, nonatomic) IBOutlet UIButton *WDNotficationBtn;
@property (weak, nonatomic) IBOutlet UIButton *WDMessageBtn;
@property (weak,nonatomic) id<WDHeaderViewForCommunityDelegate>delegate;

@end
