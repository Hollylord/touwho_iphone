//
//  loginPrompt.m
//  ZBT
//
//  Created by 投壶 on 15/9/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "loginPrompt.h"

@interface loginPrompt()
- (IBAction)quxiao:(UIButton *)sender;
- (IBAction)queding:(UIButton *)sender;


@end


@implementation loginPrompt



- (IBAction)quxiao:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(quitSelectedCancel)]) {
        [self.delegate quitSelectedCancel];
    }
    
}

- (IBAction)queding:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(quitSelectedEnsure)]) {
        [self.delegate quitSelectedEnsure];
    }
}
@end
