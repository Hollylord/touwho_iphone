//
//  WDHeaderForTopicDetailView.h
//  ZBT
//
//  Created by 投壶 on 15/9/22.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDHeaderForTopicDetailViewDelegate <NSObject>

@optional
-(void)WDTopicDetailSelectedreply;
-(void)WDTopicDetailSelectedtrans;

@end


@interface WDHeaderForTopicDetailView : UIView

@property (weak, nonatomic) IBOutlet UIButton *replyBtn;

@property (weak, nonatomic) IBOutlet UIButton *transpondBtn;

@property (weak ,nonatomic) id<WDHeaderForTopicDetailViewDelegate> delegate;

@end
