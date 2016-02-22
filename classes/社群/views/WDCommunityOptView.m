//
//  WDCommunityOptView.m
//  ZBT
//
//  Created by 投壶 on 15/9/18.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDCommunityOptView.h"

@interface WDCommunityOptView ()
- (IBAction)zuoanniu:(UIButton *)sender;

- (IBAction)youanniu:(UIButton *)sender;

@property (assign,nonatomic) BOOL leftSelected;
@property (assign,nonatomic) BOOL rightSelected;


@end

@implementation WDCommunityOptView


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self.leftSelected = YES;
    self.rightSelected = YES;
    
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}



- (IBAction)zuoanniu:(UIButton *)sender {
    
    if(self.leftSelected == YES){
        self.leftSelected = NO;
        self.rightSelected = YES;
        
        
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOptOrig"] forState:UIControlStateNormal];
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOpt"] forState:UIControlStateNormal];
        
        
        if ([self.delegate respondsToSelector:@selector(communitySelectedbtn1)]) {
            [self.delegate communitySelectedbtn1];
        }
        
    }
    
}

- (IBAction)youanniu:(UIButton *)sender {
    
    if(self.rightSelected == YES){
        self.rightSelected = NO;
        self.leftSelected = YES;
        
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOptOrig"] forState:UIControlStateNormal];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"WDCommunityOpt"] forState:UIControlStateNormal];
        

        
        if ([self.delegate respondsToSelector:@selector(communitySelectedbtn2)]) {
            [self.delegate communitySelectedbtn2];
        }
        
    }

}
@end
