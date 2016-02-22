//
//  followSelectedAlert.m
//  ZBT
//
//  Created by 投壶 on 15/10/20.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "followSelectedAlert.h"


@interface followSelectedAlert ()
- (IBAction)quxiao:(id)sender;
- (IBAction)queding:(id)sender;


@end

@implementation followSelectedAlert


- (IBAction)quxiao:(id)sender {
    if([self.delegate respondsToSelector:@selector(followSelectedCancel)]){
        [self.delegate followSelectedCancel];
    }

}

- (IBAction)queding:(id)sender {
    if([self.delegate respondsToSelector:@selector(followSelectedEnsure)]){
        [self.delegate followSelectedEnsure];
    }

}
@end
