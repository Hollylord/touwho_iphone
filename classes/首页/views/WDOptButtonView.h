//
//  WDOptButtonView.h
//  ZBT
//
//  Created by 投壶 on 15/9/16.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WDOptButtonViewDelegate <NSObject>

@optional
-(void)optSelectedjinxingzhong;
-(void)optSelectedyurezhong;
-(void)optSelectedyiwancheng;
@end

@interface WDOptButtonView : UIView
@property (weak, nonatomic) IBOutlet UIButton *jinxingzhong;

@property (weak, nonatomic) IBOutlet UIButton *yurezhong;

@property (weak, nonatomic) IBOutlet UIButton *yiwancheng;

@property (weak,nonatomic) id<WDOptButtonViewDelegate> delegate;

@end
