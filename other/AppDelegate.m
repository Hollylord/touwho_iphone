//
//  AppDelegate.m
//  ad
//
//  Created by apple on 15/7/16.
//  Copyright (c) 2015年 touwho. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import "WDTabBarController.h"


#import <AVOSCloud/AVOSCloud.h> //如果使用了实时通信模块，请添加下列导入语句到头部：
#import <AVOSCloudIM.h>

#import "TalkingData.h" // talkdata
#import "UMCheckUpdate.h"  // 检测版本更新


#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
//#import "UMSocialSinaSSOHandler.h" 微博原生




@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //设置友盟的appKey 我的：5656cf55e0f55a0a7a000f56
    [UMSocialData setAppKey:@"5656cf55e0f55a0a7a000f56"];//55af41d967e58e3f30005565
    

    //设置友盟里微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wxda59dbb0b85e6255" appSecret:@"d4624c36b6795d1d99dcf0547af5443d" url:@"http://www.umeng.com/social"];
    
    
    
//    //设置友盟里qq的AppId、appSecret，分享url
//    [UMSocialQQHandler setQQWithAppId:@"1104734143" appKey:@"otFu8s5Dv6u8sFBm" url:@"http://www.umeng.com/social"];
    //设置友盟里qq的AppId、appSecret，分享url
    [UMSocialQQHandler setQQWithAppId:@"1104418305" appKey:@"foM35jqFXzDe1uOj" url:@"http://www.umeng.com/social"];
    
     [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatTimeline]];
    
  
    // 设置leancloudapplicationId 即 App Id，clientKey 是 App Key。  // 这只leancloud
    [AVOSCloud setApplicationId:@"9vyUjfA3OLiQeVD3P0TojM5Y"
                      clientKey:@"QDSFGoFRxgDzohuf4JYRFvmD"];
    

    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。若在新浪后台设置我们的回调地址，“http://sns.whalecloud.com/sina2/callback”，这里可以传nil ,需要 #import "UMSocialSinaHandler.h"
//    [UMSocialSinaHandler openNewSinaSSOWithAppKey:@"1147607390" RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];  // 原生
    
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
//    // applicationId 即 App Id，clientKey 是 App Key。  // 这只leancloud    我的。。
//    [AVOSCloud setApplicationId:@"6Rbie9H9h6cLTXx3tywIQ2h2"
//                      clientKey:@"UX8uLqzHQ7dhrE0X8NNoX1qK"];
//    
//

    // talkingdata
    [TalkingData sessionStarted:@"E4A64C23A0CCFFDC6C752E0C65269078" withChannelId:@""];

    
    
    // 友盟检测更新；
    [UMCheckUpdate checkUpdate:@"有新版本可更新" cancelButtonTitle:@"残忍拒绝" otherButtonTitles:@"我要更新" appkey:@"5656cf55e0f55a0a7a000f56" channel:nil];
    
    
    
//    AVObject *post = [AVObject objectWithClassName:@"TestObject"];
//    [post setObject:@"Hello,World!" forKey:@"words"];
//    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            // 保存成功了！wdy
//            
//        }
//    }];

    
//NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
//    
//    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"version"] == nil) {
//        [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"version"];
//    }
//    else if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"version"] isEqualToString:version])
//    {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    UIStatusBarStyleDefault
//    UIStatusBarStyleLightContent
//    UIStatusBarStyleBlackTranslucent
//    UIStatusBarStyleBlackOpaque
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
//    WDPersonInfoView * personInfo = [[[NSBundle mainBundle] loadNibNamed:@"WDPersonInfoView" owner:self options:nil] lastObject];
    
    
    [NSThread sleepForTimeInterval:2.0];

    // 这里的application 就是    [UIApplication sharedApplication]
    // 1.创建窗口；
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
    // 2. 设置根控制器
    WDTabBarController * tabbarVC = [[WDTabBarController alloc] init];
    [tabbarVC setNeedsStatusBarAppearanceUpdate];  // 状态栏的设置;
    self.window.rootViewController = tabbarVC;
    
   // self.window.rootViewController = [[WDNewMsgViewController alloc] init];  //测试leancloud
    
    // 4、 显示窗口
    [self.window makeKeyAndVisible];
    
    
    

    
//    }
//    else {
        //  [NSThread sleepForTimeInterval:3.0];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
//    }
   
    
    return YES;
}
//微信分享 QQ分享
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
