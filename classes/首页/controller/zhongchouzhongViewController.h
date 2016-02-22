//
//  zhongchouzhongViewController.h
//  ad
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDShowProject.h"

#import "sponsorsList.h"

@interface zhongchouzhongViewController : UIViewController
@property (strong ,nonatomic) WDShowProject * model;
@property (copy ,nonatomic) NSString * type;
@property (copy ,nonatomic) NSString * userID;

@end
