//
//  RootViewController.h
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
//如果使用了实时通信模块，请添加下列导入语句到头部：
#import <AVOSCloudIM.h>


@interface RootViewController : UIViewController
@property (copy ,nonatomic) NSString * tag_ID;  // 对方的ID;

@property (nonatomic ,copy) NSString * userID; // 自己的ID；

@end
