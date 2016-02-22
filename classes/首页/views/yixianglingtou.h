//
//  yixianglingtou.h
//  ZBT
//
//  Created by 投壶 on 15/8/21.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDlingtouDelegate <NSObject>

@optional
-(void)lingtouSelectedEnsure;
-(void)lingtouSelectedCancel;

@end



@interface yixianglingtou : UIView
@property (weak, nonatomic) IBOutlet UIButton *ensure;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property(weak ,nonatomic)id<WDlingtouDelegate> delegate;

@end
