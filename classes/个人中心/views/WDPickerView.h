//
//  WDPickerView.h
//  ZBT
//
//  Created by 投壶 on 15/9/29.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDAreaModel.h"



typedef enum {
    WDPickerStyle1projectPhase,
    WDPickerStyle2,
    WDPickerStyle3shenghuidiquchengshi,
    WDPickerStyle3ruzhudanwei,
    WDPickerStyle1age,
    WDPickerStyle1suochuhangye,
    WDPickerStyle1ganxingquehangye,
    WDPickerStyle1fengxianpianhao
} WDPickerStyle;

@class WDPickerView;

@protocol WDPickerViewDelegate <NSObject>

@optional
- (void)pickerDidChaneStatus:(WDPickerView *)picker;

@end



@interface WDPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign, nonatomic) id <WDPickerViewDelegate> delegate;
@property (strong, nonatomic) WDAreaModel *locate;
@property (nonatomic) WDPickerStyle pickerStyle;
@property (weak, nonatomic) IBOutlet UIPickerView *WDpickerview;




- (id)initWithStyle:(WDPickerStyle)pickerStyle delegate:(id <WDPickerViewDelegate>)delegate;
- (void)showInView:(UIView *)view;
- (void)cancelPicker;


@end
