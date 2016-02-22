//
//  customAnnotationView.m
//  ad
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "customAnnotationView.h"
#import "popUpView.h"

@implementation customAnnotationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (self.selected == selected)
    {
        return;
    }
    if (selected)
    {
        if (self.popView == nil)
            //修改calloutView属性
            //选中时   新建并添加calloutView
            {
//                self.popView = [[[NSBundle mainBundle] loadNibNamed:@"popUpView" owner:nil options:nil] firstObject];
                
                self.popView.backgroundColor = [UIColor redColor];
                
//                if ([[UIScreen mainScreen] bounds].size.width > 375) {
//                    self.popView = [[popUpView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
//  
//                    
//                }else{
//                    self.popView = [[popUpView alloc] initWithFrame:CGRectMake(0, 0, 300, 171)];
// 
//                }
                
                self.popView = [[popUpView alloc] initWithFrame:CGRectMake(0, 0, 300, 171)];
                self.popView.mTime = self.mTime;
                self.popView.mTitle = self.mTitle;
                self.popView.mAddress = self.mAddress;
                
//                self.popView.frame = CGRectMake(0, 0, 200, 70);
                self.popView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                      -CGRectGetHeight(self.popView.bounds) / 2.f + self.calloutOffset.y);
                
                
//                if ([[UIScreen mainScreen] bounds].size.width > 375) {
//                    self.popView = [[popUpView alloc] initWithFrame:CGRectMake(0, 0, 500, 210)];
//                   // self.popView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,-CGRectGetHeight(self.popView.bounds) / 2.f + self.calloutOffset.y);
//                    
//                }
                
                
                
            }
        [self addSubview:self.popView];
    }
    else {
        [self.popView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}


-(void)setMAddress:(NSString *)mAddress{
    _mAddress = mAddress;
    NSLog(@"-----%@", self.mAddress);
}

-(void)setMTime:(NSString *)mTime{
    _mTime = mTime;
     NSLog(@"-----%@", self.mTime);
}

-(void)setMTitle:(NSString *)mTitle{
    _mTitle = mTitle;
    NSLog(@"-----%@", self.mTitle);

}
@end