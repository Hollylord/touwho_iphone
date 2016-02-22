
//
//  WDOptButtonView.m
//  ZBT
//
//  Created by 投壶 on 15/9/16.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDOptButtonView.h"

@interface WDOptButtonView()
- (IBAction)conductBtn:(UIButton *)sender;
- (IBAction)prepareBtn:(UIButton *)sender;
- (IBAction)complete:(UIButton *)sender;



@property (weak, nonatomic) IBOutlet UIImageView *btnbackground;

@property (assign ,nonatomic) BOOL jinxing;
@property (assign ,nonatomic) BOOL yure;
@property (assign ,nonatomic) BOOL wancheng;




@end


@implementation WDOptButtonView


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.jinxing = YES;
        self.yure = YES;
        self.wancheng = YES;

    }
    return self;
}


- (IBAction)conductBtn:(UIButton *)sender {
    
    if (self.jinxing == YES) {
        self.jinxing = NO;
        self.yure = YES;
        self.wancheng = YES;
        
//        [self.jinxingzhong setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        [self.yurezhong setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        [self.yiwancheng setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//
        [self.btnbackground setImage:[UIImage imageNamed:@"WDOptButton1"]];
        if ([self.delegate respondsToSelector:@selector(optSelectedjinxingzhong)]) {
            [self.delegate optSelectedjinxingzhong];
        }
        

    }
    
    
}

- (IBAction)prepareBtn:(UIButton *)sender {
    if (self.yure == YES) {
        self.yure = NO;
        self.jinxing = YES;
        self.wancheng = YES;
        
//        [self.yurezhong setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        [self.jinxingzhong setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        [self.yiwancheng setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//
        
     [self.btnbackground setImage:[UIImage imageNamed:@"WDOptButton2"]];
    if ([self.delegate respondsToSelector:@selector(optSelectedyurezhong)]) {
        [self.delegate optSelectedyurezhong];
    }
}

}

- (IBAction)complete:(UIButton *)sender {
    if (self.wancheng == YES) {
        self.wancheng = NO;
        self.jinxing = YES;
        self.yure = YES;
        
//        [self.yiwancheng setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        [self.jinxingzhong setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        [self.yurezhong setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//        
        
        [self.btnbackground setImage:[UIImage imageNamed:@"WDOptButton3"]];
        if ([self.delegate respondsToSelector:@selector(optSelectedyiwancheng)]) {
            [self.delegate optSelectedyiwancheng];
        }
    }
    
}



@end
