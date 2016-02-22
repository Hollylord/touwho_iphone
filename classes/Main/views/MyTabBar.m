//
//  MyTabBar.m
//  ad
//
//  Created by apple on 15/7/20.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "MyTabBar.h"


@interface MyTabBar ()


- (IBAction)programBtn:(id)sender; // 项目selectedIndex = 0
- (IBAction)newsBtn:(id)sender;   //新闻selectedIndex = 1
- (IBAction)foundBtn:(id)sender;   //发现
- (IBAction)BBSBtn:(id)sender;     //社区selectedIndex = 2
- (IBAction)personCenterBtn:(id)sender;   //个人中心selectedIndex = 3



@property (weak ,nonatomic) UIButton * selectedBtn;

@end



@implementation MyTabBar

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
//    self.isXiangmu = NO;
//    self.isXiangmu = NO;
//    self.isFaxian = NO;
//    self.isShequn = NO;
//    self.isGerenzhongxin = NO;
    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        // 普通状态
        [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1_5"] forState:UIControlStateNormal];
        [self.WDxinwenBtn setBackgroundImage:[UIImage imageNamed:@"btn2_5"] forState:UIControlStateNormal];
        [self.WDfaxianBtn setBackgroundImage:[UIImage imageNamed:@"btn3_5"] forState:UIControlStateNormal];
        [self.WDshequnBtn setBackgroundImage:[UIImage imageNamed:@"btn4_5"] forState:UIControlStateNormal];
        [self.WDgerenzhonxinBtn setBackgroundImage:[UIImage imageNamed:@"btn5_5"] forState:UIControlStateNormal];
        
        
        // 高亮
        [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1High_5"] forState:UIControlStateHighlighted];
        [self.WDxinwenBtn setBackgroundImage:[UIImage imageNamed:@"btn2High_5"] forState:UIControlStateHighlighted];
        [self.WDfaxianBtn setBackgroundImage:[UIImage imageNamed:@"btn3High_5"] forState:UIControlStateHighlighted];
        [self.WDshequnBtn setBackgroundImage:[UIImage imageNamed:@"btn4High_5"] forState:UIControlStateHighlighted];
        [self.WDgerenzhonxinBtn setBackgroundImage:[UIImage imageNamed:@"btn5High_5"] forState:UIControlStateHighlighted];
        
        
        // 选择
        [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1High_5"] forState:UIControlStateSelected];
        [self.WDxinwenBtn setBackgroundImage:[UIImage imageNamed:@"btn2High_5"] forState:UIControlStateSelected];
        [self.WDfaxianBtn setBackgroundImage:[UIImage imageNamed:@"btn3High_5"] forState:UIControlStateSelected];
        [self.WDshequnBtn setBackgroundImage:[UIImage imageNamed:@"btn4High_5"] forState:UIControlStateSelected];
        [self.WDgerenzhonxinBtn setBackgroundImage:[UIImage imageNamed:@"btn5High_5"] forState:UIControlStateSelected];
        
    }

    
    return self;
}





-(void)programBtn:(id)sender{  // 首页
        if(sender == self.selectedBtn) return;
    
    UIButton * btn = self.selectedBtn;
    self.selectedBtn.selected = YES;

    self.selectedBtn = sender;
    self.selectedBtn.tag = 1;
    if (btn != nil) {
        btn.selected = NO;
    }
    
    
   [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1High"] forState:UIControlStateNormal];
    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        
    }

    
    if ([self.delegate respondsToSelector:@selector(programBtnSelected)]) {
        [self.delegate programBtnSelected];
    }
    


}

-(void)newsBtn:(id)sender{  // 新闻
    
    if(sender == self.selectedBtn) return;
    
    UIButton * btn = self.selectedBtn;
    
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;

    self.selectedBtn.tag = 2;
    if (btn != nil) {
        btn.selected = NO;
    }

    
    
   [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];
    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        
    }

    if ([self.delegate respondsToSelector:@selector(newsBtnSelected)]) {
        [self.delegate newsBtnSelected];
    }
    


}

-(void)foundBtn:(id)sender{  // 发现
    
        if(sender == self.selectedBtn) return;
    UIButton * btn = self.selectedBtn;
    
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    self.selectedBtn.tag = 3;
    if (btn != nil) {
        btn.selected = NO;
    }

    
    [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];
    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        
    }

    if ([self.delegate respondsToSelector:@selector(foundBtnSelected)]) {
        [self.delegate foundBtnSelected];
    }

}

-(void)BBSBtn:(id)sender{  // 社群
    
    
        if(sender == self.selectedBtn) return;
    
    UIButton * btn = self.selectedBtn;
    
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    self.selectedBtn.tag = 4;
    if (btn != nil) {
        btn.selected = NO;
        if (btn.tag == 1) {
            [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];
        }
        
    }

    
   [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];
    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        
    }

    if ([self.delegate respondsToSelector:@selector(BBSBtnSelected)]) {
        [self.delegate BBSBtnSelected];
    }
    
    
    


}

-(void)personCenterBtn:(id)sender{  // 个人中心
    
    
        if(sender == self.selectedBtn) return;
    UIButton * btn = self.selectedBtn;
    
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    self.selectedBtn.tag = 5;
    if (btn != nil) {
        btn.selected = NO;
        if (btn.tag == 1) {
            [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];
        }
        
        
    }

//    
   [self.WDxiangmuBtn setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];

    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        
    }

    
    if ([self.delegate respondsToSelector:@selector(personCenterSelected)]) {
        [self.delegate personCenterSelected];
    }

}

@end
