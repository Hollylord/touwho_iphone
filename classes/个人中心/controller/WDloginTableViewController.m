//
//  WDloginTableViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/17.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDloginTableViewController.h"
//#import "RNBlurModalView.h"
#import "loginPrompt.h"
#import "MBProgressHUD+MJ.h"
#import "WDLoginTopTableViewCell.h"
#import "WDTabBarController.h"
#import "WDMyInfo.h"
#import <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>
#import "PAImageView.h"
#import "UIView+Extension.h"
#import "WDChangeIconViewController.h"
#import "dengluViewController.h" // 登录
#import "lingtourenViewController.h" //申请成为领头人
#import "touzirenViewController.h" //申请成为投资人
#import "publishViewController.h" //发布项目
#import "WDFQProgramViewController.h" //发起的项目
#import "WDMyProgramTableViewController.h" //投资的项目
//#import "WDGZProgramViewController.h" //关注的项目
//#import "WDGZOrganizationViewController.h" //关注的机构
//#import "WDGZPersonViewController.h" //关注的投资人

#import <AFNetworking.h>

#import "WDInfoTool.h"  // 用户信息存沙盒的工具

#import "TalkingData.h" // talkdata



// 下面的控制器
#import "personInformationViewController.h" // 个人信息



@interface WDloginTableViewController ()<WDloginPromptDelegate,WDLoginTopTableViewCellDelegate>

@property (strong,nonatomic) NSArray *items;
//@property (strong,nonatomic) RNBlurModalView *modal;
//@property (assign ,nonatomic) BOOL canSelect;
@property (assign , nonatomic) BOOL unlogin;

@property (strong ,nonatomic) UIButton * btn;
@property (strong ,nonatomic) UIButton *login;

@property (strong ,nonatomic) WDMyInfo * myInfo;
@property  (assign ,nonatomic) BOOL myInfoInit; // 控制每次程序运行只会自己在沙沙盒中加载一次信息
//@property  (assign ,nonatomic) BOOL setInfo; // 控制每次修改完个人信息后 重新加载头像；

@end

@implementation WDloginTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 不能滑动反弹；
   // self.tableView.bounces = NO;
    
    self.items = @[@"个人信息",@"申请成为领投人",@"申请成为投资人"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seccessLogin:) name:@"successLogin" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitLogin) name:@"quitLogin" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successChangeAvatar:) name:@"successChangeAvatar" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successSETInfo:) name:@"successSETInfo" object:nil];
    
    // 先把导航的右按钮设置为空
   // self.navigationItem.rightBarButtonItem = nil;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kRNBlurDidHidewNotification) name:kRNBlurDidHidewNotification object:nil];
    
   // self.canSelect = YES;
    
//    // 设置登录状态为没有登录
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // 这里面的代码，在程序运行过程中，永远只会执行1次
//        self.unlogin = YES;
//    });
    
    // 是否设置了新的头像和用户名
   // self.setInfo = NO;
    
    // 设置登录状态
    NSString * islogin = [WDInfoTool getLastAccountPlistUserID];
    if (islogin) {
        self.unlogin = NO;
        self.myInfoInit = YES;  // 这里代表要加载，因为沙盒里有数据
        NSLog(@"这里代表要加载，因为沙盒里有数据");

    }else{
        self.unlogin = YES;
        self.myInfoInit = YES;  //这里代表不用加载，因为沙盒里没有； (防止第一次进来没有更新 所以还是都要加载)
        NSLog(@"//这里代表不用加载，因为沙盒里没有");
    }
    

    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = CustomGreenColor;
    
    
    //
    
    // 设置按钮；
    UIButton * settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect settingBtnframe = CGRectMake(0, 0, 27, 27);
    settingBtn.frame = settingBtnframe;
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"WDsettingBtn"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingBtn) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];

    
    
    
//// 避免更行最新的资料不及时 所以每次进来都会重新更行本地资料一下；
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // 这里面的代码，在程序运行过程中，永远只会执行1次
//        NSString * userID = [WDInfoTool getLastAccountPlistUserID];
//        if ([userID isEqualToString:@""] || userID ==nil) {
//            [self upload:userID];
//        }
//    
//    });
    

}



// 懒加载
-(WDMyInfo *)myInfo{
    if (!_myInfo) {
         _myInfo = [[WDMyInfo alloc] init];
    }
    return _myInfo;
}


-(void)quitLogin{
    
    self.unlogin = YES;
    self.myInfo = nil;
    
    [MBProgressHUD showSuccess:@"正在退出"];
    
    // 清空登陆account信息：
    [WDInfoTool deleteAccountPlist];
    
    // 点击了退出以后 又要清空导航栏右按钮
  //  self.navigationItem.rightBarButtonItem = nil;
    
    // 设置成未登录状态；
    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
    [btn setTitle:@"请先登录" forState:UIControlStateNormal];
    btn.userInteractionEnabled = YES;
    
    // 设置小标志
    UIButton * btnM =  (UIButton *)[self.view viewWithTag:103];
    btnM.hidden = YES;
    
    //删除原来的头像
    PAImageView * image = [self.view viewWithTag:120];
    [image removeFromSuperview];
    
    
    //设置头像的按钮；
    UIButton * iconBtn = [self.view viewWithTag:101];
    [iconBtn setBackgroundImage:[UIImage imageNamed:@"default_icon"] forState:UIControlStateNormal];
    
    
    
  //  [self.modal hide];

}

-(void)settingBtn{
    NSLog(@"settingBtn");
    

    
    if (self.unlogin) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"dengluyemian"];
        [self presentViewController:viewController animated:NO completion:NULL];
        
    }
    
    if (!self.unlogin) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WDSettingsViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    
}


//-(void)kRNBlurDidHidewNotification{
//    self.canSelect = YES;
//}



//-(void)quitSelectedEnsure{
//    
//    [MBProgressHUD showSuccess:@"正在退出"];
//    
//    // 点击了退出以后 又要清空导航栏右按钮
//  //  self.navigationItem.rightBarButtonItem = nil;
//    
//    // 设置成未登录状态；
//    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
//    [btn setTitle:@"请先登录" forState:UIControlStateNormal];
//    btn.userInteractionEnabled = YES;
//
//    UIButton * btnM =  (UIButton *)[self.view viewWithTag:103];
//    btnM.hidden = YES;
//
//    
//    
//    
//    
//    [self.modal hide];
//    
//    
//    // 发送一个退出的通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"quitLogin" object:self];
//    
//}

//-(void)quitSelectedCancel{
//    [self.modal hide];
//}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    WDTabBarController * tabBar = (WDTabBarController *)self.tabBarController;
    
    if(tabBar.tabBar.hidden == YES){
        tabBar.tabBar.hidden = NO;
    }
    
    
    CGFloat curWidth =  [UIScreen mainScreen].applicationFrame.size.width;
    NSString * version = [[NSString alloc] init];
    if (curWidth > 375) version = @"iphone6p";
    if (curWidth <= 375 && curWidth >320) version = @"iphone6";
    if (curWidth <= 320) version = @"iphone5";
    NSString * str = [NSString stringWithFormat:@"个人中心,手机型号-%@",version];
    [TalkingData trackPageBegin:str];

    
    
//    NSLog(@"---%d",self.canSelect);
//    
//    
    
    
    

    
}

#pragma mark - 初始化数据-- 在这里写是为了防止从其他页面回到这里来
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.myInfoInit) {
        self.myInfoInit = NO;
        
        
        NSLog(@"初始化数据-- 在这里写是为了防止从其他页面回到这里来");
        
        NSDictionary * dict = [WDInfoTool getLastAccountPlist];
        WDMyInfo * model = [WDMyInfo objectWithKeyValues:dict];
        self.myInfo = model;
        
        
        NSLog(@"qian--%@",dict);

        if ([dict[@"resCode"] isEqualToString:@"-1000"]||dict == nil) {
            NSLog(@"防止本地的dict是空得 但是还去加载");
            
            return;
        }
        
        NSLog(@"hou--%@",dict);
        
        [self setterContentFromPliat:dict andMyinfo:model]; //从本地的数据来初始化 -并下载最新的保存 - 只下载不设置 登陆成功的才直接设置上去 这个只是更新本地数据 然后改什么我就设置什么；
    }
    
//    if (!self.unlogin){  // 如果已经退出了 就没要设置了
//        //是用个人中心回来的  就要重新获取--
//           [self reloadInfoMyinfo:self.myInfo]; // 个人设置成功后 回到这个页面就要重新设置信息；(已发通知解决)
//    }
}


// 返回多少组；
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// 返回每组有多少个cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else {
        return  self.items.count;
    }
    
}


// 返回不同的组的cell的高度；
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return 300;
    return 50;
    
}



// 返回每个组的cell;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
       WDLoginTopTableViewCell * cell =(WDLoginTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"denglu1" forIndexPath:indexPath];
        // 我这里的cell 直接在类里面写了代理。所以点击了什么 直接在类里面实现；
        cell.delegate = self;
        
        //设置选中cell时的颜色 为无色
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        BOOL unLogin = YES;
//        if (unLogin) {
//            
//            
//        }
//        
//        if (unLogin == NO) {
//            login.hidden = YES;
//        }
        
        return cell;
    }
    else {
        
        //用这个带forIndexPath的，返回指定的cell
        UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"denglu2" forIndexPath:indexPath];
        cell.contentView.backgroundColor = CustomGreenColor;
        
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        NSString *imageName = [NSString stringWithFormat:@"%@",@(indexPath.row%3 + 1)];
        imageView.image = [UIImage imageNamed:imageName];
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = self.items[indexPath.row];
        return cell;
        
        
        
    }
    
    
}


#pragma mark - 点击了用户名/请先登录
-(void)loginBtn{
    // 这个是点击了登录按钮或者用户名
    if (!self.unlogin) return;  // 如果我已经登录了。那么点击无效
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDChangeIconViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"dengluyemian"];
    
    
    [self presentViewController:viewController animated:NO completion:NULL];

    
}

#pragma mark -从本地的数据来初始化 -并下载最新的保存；
-(void)setterContentFromPliat:(NSDictionary *)dict andMyinfo:(WDMyInfo *)myInfo{
    
//    //    // 下载个人信息
//    //    [self upload:myInfo.mID];
//    
//    NSLog(@"etterContentFromPliat:(NSDictionary *)dict andMyinfo:(WDMyInfo--%@",dict);
//    
    //[self.login.l setTitle:@"登录成功用户名" forState:UIControlEventTouchUpInside];
    
    // 设置标示符的小图标
    UIButton * btnM =  (UIButton *)[self.view viewWithTag:103];
    //btnM.hidden = NO;
    
    
    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
    //设置用户的名字
    NSString * proname = [NSString stringWithFormat:@"%@",dict[@"mAccount"]];
    if (![dict[@"mNickName"] isEqualToString:@""]) {
        proname = [NSString stringWithFormat:@"%@",dict[@"mNickName"]];
    }
    if ([proname isEqualToString:@""]) {
        proname = @"请登录";
    }
    NSString * mIsInvestor = [WDInfoTool mIsInvestor];
    if ([mIsInvestor isEqualToString:@"1"]) {
        mIsInvestor = @" / 合格投资人";
        btnM.hidden = NO;
    }else{
        mIsInvestor = @"";
    }
    
    NSString * name = [NSString stringWithFormat:@"%@%@",proname,mIsInvestor];
    //[btn setTitle:name forState:UIControlStateNormal];


    
    // 设置头像 往头像上覆盖多一个avaterImageView
    UIImageView * imageView = [self.view viewWithTag:19];
    UIButton * icon =  (UIButton *)[self.view viewWithTag:101];
    CGRect newFrame = [icon.superview convertRect:icon.frame fromView:imageView];  // 以父控件为参照，父控件右上角是（0，0）
    PAImageView *  avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressColor:[UIColor clearColor] progressColor:[UIColor clearColor]  placeholderImage:[UIImage imageNamed:@"default_icon"]];
    avaterImageView.tag = 120; // 绑定一个tag;
    [avaterImageView setImageURL:myInfo.mAvatar];
    [imageView addSubview:avaterImageView];
    //把原来的头像清空 并且设置不可以鼎炉
    [icon setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn setTitle:name forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
    
    // 最后来根据这个ID下载最新的信息 以免在其他客户端改变了东西没有及时改过来  - 只下载 不设置
    [self upload:self.myInfo.mID];
}



#pragma mark - 登录成功；
-(void)seccessLogin:(NSNotification *)noti{
    self.unlogin = NO;

    NSDictionary * dict = noti.userInfo;
    WDMyInfo * myInfo  = [WDMyInfo objectWithKeyValues:dict];
    self.myInfo = myInfo;
    // 如果是登陆成功过来的数据 那就是最新的数据 所以不用重新下载了 既然是最新的 那我们再存一次沙盒;
    [WDInfoTool creatAccountPlist:dict];
    
    
    
    // 设置标示符的小图标
    UIButton * btnM =  (UIButton *)[self.view viewWithTag:103];

    //[self.login.l setTitle:@"登录成功用户名" forState:UIControlEventTouchUpInside];
    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
    //设置用户的名字
    NSString * proname = [NSString stringWithFormat:@"%@",dict[@"mAccount"]];
    if (![dict[@"mNickName"] isEqualToString:@""]) {
        proname = [NSString stringWithFormat:@"%@",dict[@"mNickName"]];
    }
    NSString * mIsInvestor = [WDInfoTool mIsInvestor];
    if ([mIsInvestor isEqualToString:@"1"]) {
        mIsInvestor = @" / 合格投资人";
        btnM.hidden = NO;
    }else{
        mIsInvestor = @"";
    }
    
    NSString * name = [NSString stringWithFormat:@"%@%@",proname,mIsInvestor];
    
    
    // 设置头像 往头像上覆盖多一个avaterImageView
    UIImageView * imageView = [self.view viewWithTag:19];
    UIButton * icon =  (UIButton *)[self.view viewWithTag:101];
    CGRect newFrame = [icon.superview convertRect:icon.frame fromView:imageView];  // 以父控件为参照，父控件右上角是（0，0）
    PAImageView *  avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressColor:[UIColor clearColor] progressColor:[UIColor clearColor]  placeholderImage:[UIImage imageNamed:@"default_icon"]];
    avaterImageView.tag = 120; // 绑定一个tag;
    [avaterImageView setImageURL:myInfo.mAvatar];
    [imageView addSubview:avaterImageView];
    //把原来的头像清空 并且设置不可以鼎炉
    [icon setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn setTitle:name forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
    
    
#pragma mark - 重新发送接收消息
    // 登录成功后 发送登录成功的通知 重新接受信息
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"loginReveiveMsg" object:self];

    

}

#pragma mark - 更新了个人信息 现在换个昵称 其他的不换，为了不卡
-(void)successSETInfo:(NSNotification *)noti{
    
   // NSLog(@"successSETInfo------%@",noti.userInfo[@"newName"]);
    // 设置标示符的小图标
    UIButton * btnM =  (UIButton *)[self.view viewWithTag:103];
    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
    //设置用户的名字
    NSString * mIsInvestor = [WDInfoTool mIsInvestor];
    if ([mIsInvestor isEqualToString:@"1"]) {
        mIsInvestor = @" / 合格投资人";
        btnM.hidden = NO;
    }else{
        mIsInvestor = @"";
    }
    
    NSString * proname = noti.userInfo[@"newName"];
    if ([proname isEqualToString:@""]) {
        NSDictionary * dict = [WDInfoTool getLastAccountPlist];
        proname = dict[@"mAccount"];
    }
    NSString * name = [NSString stringWithFormat:@"%@%@",proname,mIsInvestor];
    [btn setTitle:name forState:UIControlStateNormal];
    //[self upload:self.myInfo.mID];
}

//-(void)reloadInfoMyinfo:(WDMyInfo *)myInfo{
//    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
//    //设置用户的名字
//    NSString * name = [NSString stringWithFormat:@"%@ / 合格投资人",myInfo.mAccount];
//    if (![myInfo.mNickName isEqualToString:@""]) {
//        name = [NSString stringWithFormat:@"%@ / 合格投资人",myInfo.mNickName];
//    }
//    
//    
//    // 设置头像 往头像上覆盖多一个avaterImageView
//    UIImageView * imageView = [self.view viewWithTag:19];
//    UIButton * icon =  (UIButton *)[self.view viewWithTag:101];
//    CGRect newFrame = [icon.superview convertRect:icon.frame fromView:imageView];  // 以父控件为参照，父控件右上角是（0，0）
//    PAImageView *  avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressColor:[UIColor clearColor] progressColor:[UIColor clearColor]  placeholderImage:[UIImage imageNamed:@"touxiang"]];
//    avaterImageView.tag = 120; // 绑定一个tag;
//    [avaterImageView setImageURL:myInfo.mAvatar];
//    [imageView addSubview:avaterImageView];
//    //把原来的头像清空 并且设置不可以鼎炉
//    [icon setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [btn setTitle:name forState:UIControlStateNormal];
//    btn.userInteractionEnabled = NO;
//
//}

#pragma mark -更新了头像-
-(void)successChangeAvatar:(NSNotification *)noti{
    NSDictionary * dict = noti.userInfo;
    NSString * icon = dict[@"mAvatar"];
    PAImageView *  avaterImageView = [self.view viewWithTag:120];
    [avaterImageView setImageURL:icon];
    
    //因为头像更新了 所以我们要重新保存最新的信息；
 //   [self upload:self.myInfo.mID];
}


#pragma mark - 下载跟新个人信息 - 只下载 不设置
-(void)upload:(NSString *)mID{
    
    
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getMyInfo";
    params[@"user_id"] = mID;//
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";

    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--下载跟新个人信息-%@", responseObject);
        
        
        //获得用户数据的第一个数组 (花括号就是字典，括号就是数组)
       NSDictionary * dic  = [[responseObject objectForKey:@"value"] firstObject];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        // 判断是否为默认图片
        NSString * str1 = dict[@"mAvatar"];
        
        if (![dict[@"mAvatar"] isEqualToString:@""]) {
            str1 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str1];
        }
        dict[@"mAvatar"] = str1;
//        NSLog(@"mAva = %@",str1);
        
        // 拼接名片
        NSString * str3 = dict[@"mCardUrl"];
        if (![dict[@"mCardUrl"] isEqualToString:@""]) {
            str3 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str3];
        }
        dict[@"mCardUrl"] = str3;
        
        
        NSLog(@"请求成功--下载跟新个人信息--%@",dict);
        
        WDMyInfo * newModel = [WDMyInfo objectWithKeyValues:dict];
        self.myInfo = newModel;
        
        // 更新了最新的 我们要重新保存一遍
        [WDInfoTool creatAccountPlist:dict];

        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
//        
//        [MBProgressHUD hideHUDForView:window animated:YES];
//        [MBProgressHUD showError:@"网络连接错误"];
//        
        
    }];

    
}


#pragma mark - 点击了头像
-(void)clickIconBtn{
    // 如果没有登录就跳转登录页面
    if (self.unlogin) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        dengluViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"dengluyemian"];
        [self presentViewController:viewController animated:NO completion:NULL];
        
        return;
    }
    
    
    WDChangeIconViewController * controller =[self.storyboard instantiateViewControllerWithIdentifier:@"genghuantouxiang"];
    controller.hidesBottomBarWhenPushed = YES;
    controller.iconUrl = self.myInfo.mAvatar;
    controller.mID = self.myInfo.mID;
    PAImageView *  avaterImageView = [self.view viewWithTag:120];
    controller.image = avaterImageView.imageIcon;
    [self.navigationController pushViewController:controller animated:YES];
    
}



#pragma mark - 选中了某个cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    // 如果没有登录就跳转登录页面
    if (self.unlogin) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        dengluViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"dengluyemian"];
        [self presentViewController:viewController animated:NO completion:NULL];
        return;
    }

    
    
    if (indexPath.section == 1 && indexPath.row == 0) {
//个人信息
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        personInformationViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDpersonInformationViewController"];
       // controller.hidesBottomBarWhenPushed = YES;
     //   controller.myInfo = self.myInfo;
        [self.navigationController pushViewController:controller animated:YES];

        
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        BOOL isCanInvestor = [WDInfoTool isCanInvestor];
        if (!isCanInvestor) {
            [MBProgressHUD showError:@"请完善个人信息"];
        }else{

        NSString * mIsFirstInvestor = [WDInfoTool mIsFirstInvestor];
        if ([mIsFirstInvestor isEqualToString:@"1"]) {
            [MBProgressHUD showSuccess:@"您已经是领投人"];
            return;
        }
            
            
            
// 申请成为领头人
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        touzirenViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDtouzirenViewController"];
        // controller.hidesBottomBarWhenPushed = YES;
        controller.mID = self.myInfo.mID;
        [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        BOOL isCanInvestor = [WDInfoTool isCanInvestor];
        if (!isCanInvestor) {
            [MBProgressHUD showError:@"请完善个人信息"];
        }else{
    
        NSString * mIsInvestor = [WDInfoTool mIsInvestor];
        if ([mIsInvestor isEqualToString:@"1"]) {
            [MBProgressHUD showSuccess:@"您已经是投资人"];
            return;
        }
            
            
// 申请成为投资人
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        lingtourenViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDlingtourenViewController"];
        // controller.hidesBottomBarWhenPushed = YES;
        controller.mID = self.myInfo.mID;
        [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
    
    
    
    
//    if (indexPath.section == 1 && indexPath.row == 6) {
//// 关注的项目
//        //  myProgramTableViewController
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        WDGZProgramViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGZProgramViewController"];
//        controller.hidesBottomBarWhenPushed = YES;
//        controller.mID = self.myInfo.mID;
//        [self.navigationController pushViewController:controller animated:YES];
//        
//    }
//
//    if (indexPath.section == 1 && indexPath.row == 7) {
//// 关注的机构
//        //  myProgramTableViewController
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        WDGZOrganizationViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGZOrganizationViewController"];
//        controller.hidesBottomBarWhenPushed = YES;
//        controller.mID = self.myInfo.mID;
//        [self.navigationController pushViewController:controller animated:YES];
//        
//    }
//
//    if (indexPath.section == 1 && indexPath.row == 8) {
//// 关注的投资人
//        //  myProgramTableViewController
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        WDGZPersonViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGZPersonViewController"];
//        controller.hidesBottomBarWhenPushed = YES;
//        controller.mID = self.myInfo.mID;
//        [self.navigationController pushViewController:controller animated:YES];
//        
//    }

//    if (indexPath.section == 1 && indexPath.row == 9) {
//        //  [self performSegueWithIdentifier:@"person2myprogram" sender:nil];  // 风险
//        //  myProgramTableViewController
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDMyProgramTableViewController"];
//        controller.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:controller animated:YES];
//        
//    }

    
}

//点击我投资的项目
- (IBAction)investedProgramClick:(UIButton *)sender {
    
    //  myProgramTableViewController
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDMyProgramTableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDMyProgramTableViewController"];
    controller.hidesBottomBarWhenPushed = YES;
    controller.mID = self.myInfo.mID;
    [self.navigationController pushViewController:controller animated:YES];

}

//点击我发起的项目
- (IBAction)publishedProgramClick:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDFQProgramViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDFQProgramViewController"];
    controller.hidesBottomBarWhenPushed = YES;
    controller.mID = self.myInfo.mID;
    [self.navigationController pushViewController:controller animated:YES];
}

//点击 发布项目
- (IBAction)publishClick:(UIButton *)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    publishViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDpublishViewController"];
    //controller.hidesBottomBarWhenPushed = YES;
    controller.mID = self.myInfo.mID;
    [self.navigationController pushViewController:controller animated:YES];
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    CGFloat curWidth =  [UIScreen mainScreen].applicationFrame.size.width;
    NSString * version = [[NSString alloc] init];
    if (curWidth > 375) version = @"iphone6p";
    if (curWidth <= 375 && curWidth >320) version = @"iphone6";
    if (curWidth <= 320) version = @"iphone5";
    NSString * str = [NSString stringWithFormat:@"个人中心,手机型号-%@",version];
    [TalkingData trackPageEnd:str];
}


#pragma mark - 在系统调用dealloc的时候 把这个页面页面的观察者删除了
- (void)dealloc {
    NSLog(@"dealloc - 个人中心");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
