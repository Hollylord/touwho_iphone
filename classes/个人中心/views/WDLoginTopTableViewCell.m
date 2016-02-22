//
//  WDLoginTopTableViewCell.m
//  ZBT
//
//  Created by 投壶 on 15/9/17.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDLoginTopTableViewCell.h"

@interface WDLoginTopTableViewCell ()
- (IBAction)WDLoginTX:(UIButton *)sender;

- (IBAction)WDLoginDL:(UIButton *)sender;


@end


@implementation WDLoginTopTableViewCell



- (IBAction)WDLoginTX:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickIconBtn)] ) {
        [self.delegate clickIconBtn];
    }
    
}

- (IBAction)WDLoginDL:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(loginBtn)]) {
        [self.delegate loginBtn];
    }
}
@end
