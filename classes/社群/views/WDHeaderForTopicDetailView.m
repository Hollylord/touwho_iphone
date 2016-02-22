//
//  WDHeaderForTopicDetailView.m
//  ZBT
//
//  Created by 投壶 on 15/9/22.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDHeaderForTopicDetailView.h"


@interface WDHeaderForTopicDetailView()
- (IBAction)huifu:(UIButton *)sender;

- (IBAction)zhuanfa:(UIButton *)sender;
//
//@property (assign,nonatomic) BOOL replaySelected;
//@property (assign,nonatomic) BOOL transSelected;


@end

@implementation WDHeaderForTopicDetailView



-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
//    self.replaySelected = YES;
//    self.transSelected = YES;
//    
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


- (IBAction)huifu:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(WDTopicDetailSelectedreply)]) {
        [self.delegate WDTopicDetailSelectedreply];
    }
    
    
    
}

- (IBAction)zhuanfa:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(WDTopicDetailSelectedtrans)]) {
        [self.delegate WDTopicDetailSelectedtrans];
    }

}
@end
