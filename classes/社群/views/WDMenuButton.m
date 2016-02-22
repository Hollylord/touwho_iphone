//
//  WDMenuButton.m
//  ZBT
//
//  Created by 投壶 on 15/9/14.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDMenuButton.h"
#define KImagePercent 0.8


@implementation WDMenuButton



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // 设置按钮； 设置button如果没有forState  就没有效果了
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        //设置图片等比例显示
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        //[self.imageView setContentMode:UIViewContentModeCenter];
        
    }
    return self;
}

/**
 * - (CGRect)backgroundRectForBounds:(CGRect)bounds;   //按钮本身背景的大小
 * - (CGRect)contentRectForBounds:(CGRect)bounds;      // 文本和图片的组合大小；
 * - (CGRect)titleRectForContentRect:(CGRect)contentRect;
 * - (CGRect)imageRectForContentRect:(CGRect)contentRect;
 
 */
#pragma mark - 设置按钮的文本;
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat imageH = contentRect.size.height * KImagePercent;
    CGFloat titleH = contentRect.size.height - imageH;
    return CGRectMake(0, imageH +3, contentRect.size.width, titleH);
}


#pragma mark -设置按钮的image
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageH = contentRect.size.height * KImagePercent-3;
    CGFloat imageW = contentRect.size.width ;   // * KImagePercent;
    return CGRectMake(0, 0, imageW, imageH);
}

@end
