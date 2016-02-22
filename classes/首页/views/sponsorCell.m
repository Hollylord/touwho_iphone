//
//  sponsorCell.m
//  touwhoIphone
//
//  Created by 投壶 on 15/11/23.
//  Copyright © 2015年 投壶. All rights reserved.
//

#import "sponsorCell.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>


@interface sponsorCell ()


@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *touzijine;

@property (weak, nonatomic) IBOutlet UILabel *figure;


@end

@implementation sponsorCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setModel:(WDInvestorList *)model{
    _model = model;
    // 头像
    [self.icon sd_setImageWithURL:[NSURL URLWithString:model.mAvatar] placeholderImage:[UIImage imageNamed:@"touhu"]];
    
    // 名字
    [self.name setText:model.mName];
    
    //金额
    NSString * str = [NSString stringWithFormat:@"%@万元",model.mInvestMoney];
    [self.figure setText:str];
    
}

-(void)setType:(NSString *)type{
    _type = type;
    if ([type isEqualToString:@"fqr"]) {
        self.touzijine.hidden = YES;
        self.figure.hidden = YES;
    }else{
        self.touzijine.hidden = NO;
        self.figure.hidden = NO;
 
    }
}




@end
