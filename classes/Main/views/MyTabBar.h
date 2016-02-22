//
//  MyTabBar.h
//  ad
//
//  Created by apple on 15/7/20.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>


//- (IBAction)programBtn:(id)sender; // 项目selectedIndex = 0
//- (IBAction)newsBtn:(id)sender;   //新闻selectedIndex = 1
//- (IBAction)foundBtn:(id)sender;   //发现
//- (IBAction)BBSBtn:(id)sender;     //社区selectedIndex = 2
//- (IBAction)personCenterBtn:(id)sender;   //个人中心selectedIndex = 3


@protocol MyTabBarDelegate <NSObject>

@optional
// 项目
-(void)programBtnSelected;
//新闻
-(void)newsBtnSelected;
// 发现
-(void)foundBtnSelected;
// 社区
-(void)BBSBtnSelected;
// 个人中心
-(void)personCenterSelected;


@end


@interface MyTabBar : UIView
@property (weak, nonatomic) IBOutlet UIButton *WDxiangmuBtn;
@property (weak, nonatomic) IBOutlet UIButton *WDxinwenBtn;
@property (weak, nonatomic) IBOutlet UIButton *WDfaxianBtn;
@property (weak, nonatomic) IBOutlet UIButton *WDshequnBtn;
@property (weak, nonatomic) IBOutlet UIButton *WDgerenzhonxinBtn;

@property (weak , nonatomic) id<MyTabBarDelegate>delegate;


@end
