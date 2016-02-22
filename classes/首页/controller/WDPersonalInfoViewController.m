//
//  WDPersonalInfoViewController.m
//  ZBT
//
//  Created by 投壶 on 15/10/9.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDPersonalInfoViewController.h"
#import "UIView+Extension.h"
//#import "WDPersonInfoView.h"
#import "RootViewController.h" // 私信
#import "MBProgressHUD+MJ.h"
#import "WDLoginTopTableViewCell.h"
#import "WDTabBarController.h"
#import "WDMyInfo.h"
#import <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>
#import "PAImageView.h"
#import "UIView+Extension.h"
#import <AFNetworking.h>
#import "WDInfoTool.h"  // 用户信息存沙盒的工具

#import "WDTopicButton.h" // 多一个tag

#import "WDMyInfo.h"


#import "WDFQProgramViewController.h"
#import "WDMyProgramTableViewController.h"


#import "WDPersonModel.h" // 个人信息卡片


#define ListHeight 190

@interface WDPersonalInfoViewController ()
@property (strong,nonatomic) NSArray *items;

@property(nonatomic ,strong) NSMutableArray * animationRows;
@property(nonatomic ,assign) BOOL IsOpen;
//@property (nonatomic,strong) WDPersonInfoView * personInfo;
@property (nonatomic,strong) UIView * personInfo;

@property (strong ,nonatomic) WDMyInfo * targetInfo;

@property (strong ,nonatomic) NSMutableDictionary * dict ;

@property (strong , nonatomic)  WDPersonModel * personmodel;

@end

@implementation WDPersonalInfoViewController

-(NSMutableDictionary *)dict{
    if (!_dict) {
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.items = @[@"个人简介",@"发起的项目",@"投资的项目"];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.IsOpen = NO;
    
    
//    // 加载这个会卡 所以放在这里操作；
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // 执行耗时的异步操作...
//        
//        WDPersonInfoView * personInfo = [[[NSBundle mainBundle] loadNibNamed:@"WDPersonInfoView" owner:nil options:nil] lastObject];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 回到主线程，执行UI刷新操作
//           // self.personInfo = personInfo;
//
//        });
//    });
    
//    
//    WDPersonInfoView * personInfo = [[[NSBundle mainBundle] loadNibNamed:@"WDPersonInfoView" owner:self options:nil] lastObject];
    
    [self setPersonView];

    // 请求所点击的人得信息
    [self upload:self.target_id];
    

    
}


-(void)setPersonView{
    
    
    UIView * personInfo = [[UIView alloc] init];
    [personInfo setBackgroundColor:[UIColor whiteColor]];
    self.personInfo = personInfo;
    
    
    CGFloat x = 5;
    CGFloat y = 0 ;
    CGFloat width = self.view.frame.size.width -10;
    CGFloat height = 180;


    
    // 创建一个姓名；
    UILabel * name = [[UILabel alloc] init];
    name.frame = CGRectMake(x+15, y+21, 42, 21);
    [name setFont:[UIFont systemFontOfSize:14]];
    [name setText:@"姓名:"];
    [self.personInfo addSubview:name];
    
    UILabel * nameVal = [[UILabel alloc] init];
    nameVal.frame = CGRectMake(x+15+42, y+21, 93, 21);
    [nameVal setFont:[UIFont systemFontOfSize:14]];
    nameVal.tag = 201; // 设置姓名
    [nameVal setText:self.personmodel.name];
    [self.personInfo addSubview:nameVal];
    
    // 创建一个性别；
    UILabel * sex = [[UILabel alloc] init];
    sex.frame = CGRectMake(x+15+42+93+40, y+21, 42, 21);
    [sex setFont:[UIFont systemFontOfSize:14]];
    [sex setText:@"性别:"];
    [self.personInfo addSubview:sex];
    
    UILabel * sexVal = [[UILabel alloc] init];
    sexVal.frame = CGRectMake(x+15+42+93+40+42, y+21, 42, 21);
    [sexVal setFont:[UIFont systemFontOfSize:14]];
    sexVal.tag = 202; // 设置性别
    [sexVal setText:self.personmodel.sex];
    [self.personInfo addSubview:sexVal];
    
    
    // 创建一个投资理念；
    UILabel * pri = [[UILabel alloc] init];
    pri.frame = CGRectMake(x+15, y+21+21+15, 70, 21);
    [pri setFont:[UIFont systemFontOfSize:14]];
    [pri setText:@"投资理念:"];
    [self.personInfo addSubview:pri];
    
    UITextView * priVal = [[UITextView alloc] init];
    priVal.frame = CGRectMake(x+15+70+5, y+21+21+15-6, width-x-15-70-5, height -y-21-21-15);
    [priVal setFont:[UIFont systemFontOfSize:14]];
    [priVal setText:self.personmodel.text];
    priVal.tag = 203;//设置投资理念；
    priVal.scrollEnabled = YES;
    priVal.editable = NO;
    priVal.textAlignment = NSTextAlignmentNatural;
    [self.personInfo addSubview:priVal];
    

}

//
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//
//    // 刷新一下
//    [self.tableView reloadData];
//
//
//}

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
        
        
        //获得用户数据的第一个数组 (花括号就是字典，括号就是数组)
        NSDictionary * dic  = [[responseObject objectForKey:@"value"] firstObject];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        // 判断是否为默认图片
        NSString * str1 = dict[@"mAvatar"];
        if (![dict[@"mAvatar"] isEqualToString:@""]) {
            str1 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str1];
        }
        dict[@"mAvatar"] = str1;
        
        // 拼接名片
        NSString * str3 = dict[@"mCardUrl"];
        if (![dict[@"mCardUrl"] isEqualToString:@""]) {
            str3 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str3];
        }
        dict[@"mCardUrl"] = str3;
        
        NSLog(@"请求成功--别人的个人信息-%@", dict);

        self.dict = dict;
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }

        
        //NSLog(@"请求成功--下载跟新个人信息--%@",dict); 来到这里就是灭有问题了
        
        WDMyInfo * newModel = [WDMyInfo objectWithKeyValues:dict];
       self.targetInfo = newModel;
        
        
        
        
        // 设置个人信息卡片；

        WDPersonModel * model = [[WDPersonModel alloc] init];
        model.name  = dict[@"mNickName"];
        model.sex = dict[@"mSex"];
        // 性别
        if ([model.sex isEqualToString:@"1"]) { //女生
            model.sex = @"女士";
        }else{//男生；
            model.sex= @"先生";
        }
        model.text = dict[@"mDes"];
        
        
  //      self.personInfo.personmodel = model;
        self.personmodel = model;
        
        
//        // 刷新一下
//        [self.tableView reloadData];
        

    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        [MBProgressHUD showError:@"网络连接错误"];


    }];
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }
    return 0;
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
    if (indexPath.section == 0) {
        return 180;
    }
    
    return 50;
    
}



// 返回每个组的cell;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"denglu1"forIndexPath:indexPath];

//        
//        // 设置标示符的小图标
//        UIButton * btnM =  (UIButton *)[cell viewWithTag:103];
//        
//        //[self.login.l setTitle:@"登录成功用户名" forState:UIControlEventTouchUpInside];
//        UIButton * btn =  (UIButton *)[cell viewWithTag:102];
//        //设置用户的名字
//        NSString * proname = [NSString stringWithFormat:@"%@",self.targetInfo.mAccount];
//        if (![self.targetInfo.mNickName isEqualToString:@""]) {
//            proname = [NSString stringWithFormat:@"%@",self.targetInfo.mNickName];
//        }
//        NSString * mIsInvestor = self.targetInfo.mIsInvestor;
//        if ([mIsInvestor isEqualToString:@"1"]) {
//            mIsInvestor = @" / 合格投资人";
//            btnM.hidden = NO;
//        }else{
//            mIsInvestor = @"";
//        }
//        
//        NSString * name = [NSString stringWithFormat:@"%@%@",proname,mIsInvestor];
//        
//        
//        // 设置头像 往头像上覆盖多一个avaterImageView
//        UIImageView * imageView = [self.view viewWithTag:19];
//        UIButton * icon = [self.view viewWithTag:101];  // 搜索这个首先要有frame;
//        CGRect newFrame = [icon.superview convertRect:icon.frame fromView:imageView];  // 以父控件为参照，父控件右上角是（0，0）
//        //CGRect newFrame = icon.frame;
//        
////        PAImageView *  avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressolor:[UIColor clearColor] progressColor:[UIColor clearColor]  placeholderImage:[UIImage imageNamed:@"touxiang"]];
//        
//        
//        PAImageView *avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressColor:[UIColor clearColor] progressColor:[UIColor clearColor] placeholderImage:[UIImage imageNamed:@"touxiang"]];
//        
//        avaterImageView.tag = 120; // 绑定一个tag;
//        
//        NSLog(@"self.targetInfo.mAvatar--%@",self.dict[@"mAvatar"]);
//        NSString *str = self.targetInfo.mAvatar;
//        NSLog(@"%@",str);
//        
//        [avaterImageView setImageURL:self.dict[@"mAvatar"]];
//        
//        //把原来的头像清空 并且设置不可以鼎炉
//        [icon setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//                [btn setTitle:name forState:UIControlStateNormal];
//        btn.userInteractionEnabled = NO;
//        
//        // 设置私信按钮
//        UIButton * chat = [cell viewWithTag:104];
//        [chat addTarget:self action:@selector(clickChat) forControlEvents:UIControlEventTouchUpInside];
//
        
        return cell;
    }
    else {
        
        UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"denglu2" forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        NSString *imageName = [NSString stringWithFormat:@"%@",@(indexPath.row%7 + 1)];
        imageView.image = [UIImage imageNamed:imageName];
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = self.items[indexPath.row];
        
        UIButton * btn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        btn.frame = cell.contentView.frame;
        btn.tag = 111;
        [btn addTarget:self action:@selector(cellclickbtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = YES;
        [cell addSubview:btn];
        
        
        return cell;
        
        
        
    }
    
    
    
}

-(NSMutableArray *)animationRows{
    if (!_animationRows) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.tableView indexPathsForVisibleRows]];
        self.animationRows = array;
    }
    return _animationRows;
}

-(void)cellclickbtn:(UIButton*)btn{

    self.IsOpen = NO;
    [UIView animateWithDuration:0.25f animations:^{
        for(NSIndexPath* Path in self.animationRows) {
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:Path];
            UIButton * btn = (UIButton *)[cell viewWithTag:111];
            btn.hidden = YES;

            if (Path.row !=0){
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:Path];
                CGRect newframe = cell.frame;
                newframe.origin.y -= ListHeight;
                cell.frame = newframe;}
        }
    }];
    [self.personInfo removeFromSuperview];
}


// 选中某个cell的响应；

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    

    if (indexPath.section == 1 && indexPath.row == 0) {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        // 1) 选中单元格的y
        CGFloat cellY = cell.frame.origin.y;
        // 2) 选中单元格的行高
        CGFloat cellHeight = cell.frame.size.height;
        // 3) 准备插入子视图的Y
        CGFloat subViewY = cellY + cellHeight;

        
        

        if (self.IsOpen ==NO) {
            self.IsOpen = YES;
            
            
            
            [UIView animateWithDuration:0.25f animations:^{
                for(NSIndexPath* Path in self.animationRows) {
                    UITableViewCell * cell = [tableView cellForRowAtIndexPath:Path];
                    UIButton * btn = (UIButton *)[cell viewWithTag:111];
                    btn.hidden = NO;
                    if (indexPath.row != Path.row){
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:Path];
                        CGRect newframe = cell.frame;
                        newframe.origin.y += ListHeight;
                        cell.frame = newframe;}
                }
            }];
//
//#warning mark - 加载xib
//            WDPersonInfoView * personInfo = [[[NSBundle mainBundle] loadNibNamed:@"WDPersonInfoView" owner:nil options:nil] lastObject];
//            self.personInfo = personInfo;
            
            CGFloat x = 5;
            CGFloat y = subViewY + 5 ;
            CGFloat width = self.view.frame.size.width -10;
            CGFloat height = 180;
            
            self.personInfo.frame  = CGRectMake(x,y,width,height);
            

            UILabel *nameVal = [self.personInfo viewWithTag:201];
            [nameVal setText:self.personmodel.name];
            
            UILabel *sexVal = [self.personInfo viewWithTag:202];
            [sexVal setText:self.personmodel.sex];
            
            UITextView * priVal = [self.personInfo viewWithTag:203];
            [priVal setText:self.personmodel.text];
            
            
            [self.view insertSubview:self.personInfo atIndex:0];

            

        }else{
            self.IsOpen = NO;
            [UIView animateWithDuration:0.25f animations:^{
                for(NSIndexPath* Path in self.animationRows) {
                    UITableViewCell * cell = [tableView cellForRowAtIndexPath:Path];
                    UIButton * btn = (UIButton *)[cell viewWithTag:111];
                    btn.hidden = NO;

                    if (indexPath.row != Path.row){
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:Path];
                        CGRect newframe = cell.frame;
                        newframe.origin.y -= ListHeight;
                        cell.frame = newframe;}
                }
            }];
            
            [self.personInfo removeFromSuperview];

            
            
        }
    }
    
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        NSString * userID = [WDInfoTool getLastAccountPlistUserID];
        if ([userID isEqualToString:@""] || userID ==nil) {
            [MBProgressHUD showError:@"请先登录"];
            return;
        }

        // 我发起的项目
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDFQProgramViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDFQProgramViewController"];
        controller.hidesBottomBarWhenPushed = YES;
        controller.mID = self.target_id;
        [self.navigationController pushViewController:controller animated:YES];
        
        
    }
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        NSString * userID = [WDInfoTool getLastAccountPlistUserID];
        if ([userID isEqualToString:@""] || userID ==nil) {
            [MBProgressHUD showError:@"请先登录"];
            return;
        }

        // 我投资的项目
        //  myProgramTableViewController
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WDMyProgramTableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDMyProgramTableViewController"];
        controller.hidesBottomBarWhenPushed = YES;
        controller.mID = self.target_id;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
       
    
}


-(void)clickChat{
    NSLog(@"clickChat");
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    
    
    RootViewController * controller = [[RootViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.tag_ID = self.target_id;
    controller.userID = userID;
    [self.navigationController pushViewController:controller animated:YES];
    
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 设置标示符的小图标
    UIButton * btnM =  (UIButton *)[self.view viewWithTag:103];
    
    //[self.login.l setTitle:@"登录成功用户名" forState:UIControlEventTouchUpInside];
    UIButton * btn =  (UIButton *)[self.view viewWithTag:102];
    //设置用户的名字
    NSString * proname = [NSString stringWithFormat:@"%@",self.targetInfo.mAccount];
    if (![self.targetInfo.mNickName isEqualToString:@""]) {
        proname = [NSString stringWithFormat:@"%@",self.targetInfo.mNickName];
    }
    NSString * mIsInvestor = self.targetInfo.mIsInvestor;
    if ([mIsInvestor isEqualToString:@"1"]) {
        mIsInvestor = @" / 合格投资人";
        btnM.hidden = NO;
    }else{
        mIsInvestor = @"";
    }
    
    NSString * name = [NSString stringWithFormat:@"%@%@",proname,mIsInvestor];
    
    
    // 设置头像 往头像上覆盖多一个avaterImageView
    UIImageView * imageView = [self.view viewWithTag:19];
    UIButton * icon = [self.view viewWithTag:101];  // 搜索这个首先要有frame;
    CGRect newFrame = [icon.superview convertRect:icon.frame fromView:imageView];  // 以父控件为参照，父控件右上角是（0，0）
    //CGRect newFrame = icon.frame;
    
    //        PAImageView *  avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressolor:[UIColor clearColor] progressColor:[UIColor clearColor]  placeholderImage:[UIImage imageNamed:@"touxiang"]];
    
    
    PAImageView *avaterImageView = [[PAImageView alloc] initWithFrame:newFrame backgroundProgressColor:[UIColor clearColor] progressColor:[UIColor clearColor] placeholderImage:[UIImage imageNamed:@"default_icon"]];
    
    avaterImageView.tag = 120; // 绑定一个tag;
    
    NSLog(@"self.target_iconUrl--%@",self.target_iconUrl);
//    NSString *str = self.targetInfo.mAvatar;
//    NSLog(@"%@",str);
    
    [avaterImageView setImageURL:self.target_iconUrl];
    [imageView addSubview:avaterImageView];

    //把原来的头像清空 并且设置不可以鼎炉
    [icon setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn setTitle:name forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
    
    // 设置私信按钮
    UIButton * chat = [self.view viewWithTag:104];
    [chat addTarget:self action:@selector(clickChat) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    tab.tabBar.hidden = YES;

}

@end
