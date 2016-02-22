//
//  WDHeaderViewForCommunity.m
//  ZBT
//
//  Created by 投壶 on 15/9/15.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDHeaderViewForCommunity.h"

@interface WDHeaderViewForCommunity ()


- (IBAction)WDNoti:(UIButton *)sender;
- (IBAction)WDMessage:(UIButton *)sender;


@property (assign,nonatomic) BOOL notiSelected;
@property (assign,nonatomic) BOOL messageSelected;


@end


@implementation WDHeaderViewForCommunity





-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self.notiSelected = YES;
    self.messageSelected = YES;

    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.WDMessageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.WDNotficationBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (IBAction)WDNoti:(UIButton *)sender {
    [self.WDNotficationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.WDMessageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    if (self.notiSelected == YES) {
        self.notiSelected = NO;
        self.messageSelected = YES;
        if ([self.delegate respondsToSelector:@selector(WDHeaderViewForCommunitySelsctedNoti)]) {
            [self.delegate WDHeaderViewForCommunitySelsctedNoti];
        }

    }
    
    
    
}

- (IBAction)WDMessage:(UIButton *)sender {

    [self.WDNotficationBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.WDMessageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if ( self.messageSelected == YES) {
        self.messageSelected = NO;
        self.notiSelected = YES;
    if ([self.delegate respondsToSelector:@selector(WDHeaderViewForCommunitySelsctedMessage)]) {
        [self.delegate WDHeaderViewForCommunitySelsctedMessage];
    }
  }
}
@end
