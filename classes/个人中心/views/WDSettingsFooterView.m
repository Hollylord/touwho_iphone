//
//  WDSettingsFooterView.m
//  ZBT
//
//  Created by 投壶 on 15/10/26.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDSettingsFooterView.h"

@interface WDSettingsFooterView ()
- (IBAction)quit:(id)sender;

@end

@implementation WDSettingsFooterView
- (IBAction)quit:(id)sender {
    
    NSLog(@"发送一个退出的通知");
    
    // 发送一个退出的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"quitLogin" object:self];
    
    if ([self.delegate respondsToSelector:@selector(WDSettingsFooterViewQuit)]) {
        [self.delegate WDSettingsFooterViewQuit];
    }
    
    // 把本地的聊天记录删除了
    NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString * plistPath = [caches stringByAppendingString:@"/Plist"];
    //先创建这个文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    // 文件正确位置
    NSString *fileName = [plistPath stringByAppendingPathComponent:@"messages.plist"];
    [fileManager removeItemAtPath:fileName error:nil];
    
    
    //删除sdweb的图片
    NSString * imagePath = [caches stringByAppendingString:@"/default"];
    //先创建这个文件
    [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
    // 删除这个目录
    [fileManager removeItemAtPath:imagePath error:nil];


    // 发送一个删除本地聊天信息的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteMsg" object:self];
    
}
@end
