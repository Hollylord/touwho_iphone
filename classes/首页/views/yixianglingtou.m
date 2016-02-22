//
//  yixianglingtou.m
//  ZBT
//
//  Created by 投壶 on 15/8/21.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "yixianglingtou.h"

@interface yixianglingtou()
- (IBAction)queding:(id)sender;

- (IBAction)quxiao:(id)sender;

@end


@implementation yixianglingtou

- (IBAction)queding:(id)sender {
    if ([self.delegate respondsToSelector:@selector(lingtouSelectedEnsure)]) {
        [self.delegate lingtouSelectedEnsure];
    }

    
}

- (IBAction)quxiao:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(lingtouSelectedCancel)]) {
        [self.delegate lingtouSelectedCancel];
    }

    
}
@end
