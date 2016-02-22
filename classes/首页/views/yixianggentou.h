//
//  yixianggentou.h
//  ZBT
//
//  Created by 投壶 on 15/8/27.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDgentouDelegate <NSObject>

@optional
-(void)gentouSelectedEnsure;
-(void)gentouSelectedCancel;

@end



@interface yixianggentou : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *ensureBtn;
@property(weak,nonatomic) id<WDgentouDelegate> delegate;
@end
