//
//  yixianggentou.m
//  ZBT
//
//  Created by 投壶 on 15/8/27.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "yixianggentou.h"


@interface yixianggentou ()

- (IBAction)queding:(UIButton *)sender;

- (IBAction)quxiao:(UIButton *)sender;

@end

@implementation yixianggentou


- (IBAction)queding:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(gentouSelectedEnsure)]){
        [self.delegate gentouSelectedEnsure];
    }
    
    
}

- (IBAction)quxiao:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(gentouSelectedCancel)]){
        [self.delegate gentouSelectedCancel];
    }
    
}
@end
