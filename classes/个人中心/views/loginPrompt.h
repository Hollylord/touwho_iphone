//
//  loginPrompt.h
//  ZBT
//
//  Created by 投壶 on 15/9/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDloginPromptDelegate <NSObject>

@optional
-(void)quitSelectedEnsure;
-(void)quitSelectedCancel;

@end



@interface loginPrompt : UIView

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (weak ,nonatomic) id<WDloginPromptDelegate> delegate;

@end

