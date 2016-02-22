//
//  followSelectedAlert.h
//  ZBT
//
//  Created by 投壶 on 15/10/20.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol followSelectedAlertdelegate <NSObject>

@optional
-(void)followSelectedEnsure;
-(void)followSelectedCancel;


@end

@interface followSelectedAlert : UIView
@property (weak ,nonatomic) id<followSelectedAlertdelegate>delegate;

@end
