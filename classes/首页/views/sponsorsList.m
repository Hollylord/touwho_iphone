//
//  sponsorsList.m
//  ad
//
//  Created by apple on 15/7/30.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "sponsorsList.h"
#import "zhongchouzhongViewController.h"
#import "WDInvestorList.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "sponsorCell.h"

#import "WDPersonalInfoViewController.h"

#import "WDInfoTool.h"
#import "MBProgressHUD+MJ.h"


@interface sponsorsList ()

@property (nonatomic, strong) NSArray * mFirstInvestor;
@property (nonatomic, strong) NSArray * mFollowInvestor;
@property (nonatomic, strong) NSArray * mLeaderInvestor;


@end




@implementation sponsorsList


#pragma mark - 发起人小组
-(NSArray * )mFirstInvestor{
    if (nil == _mFirstInvestor) {
        _mFirstInvestor = [NSArray array];
    }
    return _mFirstInvestor;
    
}

#pragma mark - 跟头人小组
-(NSArray * )mFollowInvestor{
    if (nil == _mFollowInvestor) {
        _mFollowInvestor = [NSArray array];
    }
    return _mFollowInvestor;
    
}

#pragma mark - 领头人小组
-(NSArray * )mLeaderInvestor{
    if (nil == _mLeaderInvestor) {
        _mLeaderInvestor = [NSArray array];
    }
    return _mLeaderInvestor;
    
}




- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
       UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"sponsorsList" owner:self options:nil] firstObject];
        [self addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self addConstraint:leading];
        [self addConstraint:trailing];
        [self addConstraint:top];
        [self addConstraint:bottom];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
            UINib *sponsorsCell = [UINib nibWithNibName:@"sponsorCell" bundle:nil];
            [self.tableView registerNib:sponsorsCell forCellReuseIdentifier:@"sponsors"];
    }
    return self;
}
#pragma mark - tableview 代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [[[NSBundle mainBundle] loadNibNamed:@"WDFaqirenHeader" owner:nil options:nil] lastObject];

    }
    
    if(section == 1){
        return [[[NSBundle mainBundle] loadNibNamed:@"WDlingtourenHeader" owner:nil options:nil] lastObject];
    }
    
    return [[[NSBundle mainBundle] loadNibNamed:@"WDTouzirenHeader" owner:nil options:nil] lastObject];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.mLeaderInvestor.count;
    }
    if(section == 1){
        return self.mFirstInvestor.count;
    }
    return self.mFollowInvestor.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    sponsorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sponsors"];
    
    // 发起人
    if(indexPath.section == 0){
        WDInvestorList * model = self.mLeaderInvestor[indexPath.row];
        cell.type = @"fqr";
        cell.model = model;
        NSLog(@"dequeueReusableCellWithIdentifier-sponsors-%@",model.mName);


    }
    
    // 领投人
    if(indexPath.section == 1){
        WDInvestorList * model = self.mFirstInvestor[indexPath.row];
        cell.type = @"ltr";
        cell.model = model;
        NSLog(@"dequeueReusableCellWithIdentifier-sponsors-%@",model.mName);


        
    }
    // 跟投人
    if(indexPath.section == 2){
        WDInvestorList * model = self.mFollowInvestor[indexPath.row];
        cell.type = @"gtr";
        cell.model = model;
        NSLog(@"dequeueReusableCellWithIdentifier-sponsors-%@",model.mName);
        
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(sponsorsListdidSelectRowAtIndexPath:)]) {
        [self.delegate sponsorsListdidSelectRowAtIndexPath:indexPath];
    }
    
//    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
//    if ([userID isEqualToString:@""] || userID ==nil) {
//        [MBProgressHUD showError:@"请先登录"];
//        return;
//    }
//
//    
//    // 发起人
//    if(indexPath.section == 0){
//        WDInvestorList * model = self.mLeaderInvestor[indexPath.row];
//        
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
//        
//        controller.user_id = userID;
//        controller.target_id = model.mID;
//        controller.target_iconUrl = model.mAvatar;
//        [self.navigationController pushViewController:controller animated:YES];
//
//        
//        
//    }
//    
//    // 领投人
//    if(indexPath.section == 1){
//        WDInvestorList * model = self.mFirstInvestor[indexPath.row];
//  
//        
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
//        
//        controller.user_id = userID;
//        controller.target_id = model.mID;
//        controller.target_iconUrl = model.mAvatar;
//        [self.navigationController pushViewController:controller animated:YES];
//
//    }
//    // 跟投人
//    if(indexPath.section == 2){
//        WDInvestorList * model = self.mLeaderInvestor[indexPath.row];
//        
//        
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
//        
//        controller.user_id = userID;
//        controller.target_id = model.mID;
//        controller.target_iconUrl = model.mAvatar;
//        [self.navigationController pushViewController:controller animated:YES];
//
//    }
//
//    
    

}


-(void)setAllInvestor:(WDAllInvestor *)allInvestor{
   // self.mFirstInvestor = allInvestor.mFirstInvestor;
//    self.mFollowInvestor = allInvestor.mFollowInvestor;
//    self.mLeaderInvestor = allInvestor.mLeaderInvestor;
//    
    self.mFirstInvestor = [NSArray arrayWithArray:allInvestor.mFirstInvestor];
    self.mFollowInvestor = [NSArray arrayWithArray:allInvestor.mFollowInvestor];
    self.mLeaderInvestor = [NSArray arrayWithArray:allInvestor.mLeaderInvestor];

    [self.tableView reloadData];
}



@end
