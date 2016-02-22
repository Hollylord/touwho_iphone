//
//  WDSettingsFooterView.h
//  ZBT
//
//  Created by 投壶 on 15/10/26.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDSettingsFooterViewDelegate <NSObject>

@optional
-(void)WDSettingsFooterViewQuit;

@end

@interface WDSettingsFooterView : UIView

@property (weak ,nonatomic) id<WDSettingsFooterViewDelegate>delegate;

@end
