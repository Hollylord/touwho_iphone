//
//  WDCommunityOptView.h
//  ZBT
//
//  Created by 投壶 on 15/9/18.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDCommunityOptViewDelegate <NSObject>

@optional
-(void)communitySelectedbtn1;
-(void)communitySelectedbtn2;

@end


@interface WDCommunityOptView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

@property (weak,nonatomic) id<WDCommunityOptViewDelegate>delegate;
@end
