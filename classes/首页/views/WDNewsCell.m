//
//  WDNewsCell.m
//  UIScrollView-无限循环
//
//  Created by 222ying on 15/7/26.
//  Copyright (c) 2015年 222ying. All rights reserved.
//

#import "WDNewsCell.h"
#import "WDnews.h"
//#import "MJArgument.h"
#import <SDWebImage/UIImageView+WebCache.h>



@interface WDNewsCell()
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@end



@implementation WDNewsCell
- (void)setNews:(WDnews *)news
{
    _news = news;
//    self.iconView.image = [UIImage imageNamed:@"picture6p4"];
////   // self.titleLabel.text = [NSString stringWithFormat:@"  %@", news.title];
//    
//    NSLog(@"-----%@",news.mImageUrl);

    [self.iconView sd_setImageWithURL:[NSURL URLWithString:news.mImageUrl] placeholderImage:[UIImage imageNamed:@"default_750_358"]];
    

}
@end
