//
//  sponsorsList.h
//  ad
//
//  Created by apple on 15/7/30.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDAllInvestor.h"

@protocol sponsorsListDelegate <NSObject>
@optional
-(void)sponsorsListdidSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface sponsorsList : UIView <UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic) id<sponsorsListDelegate>delegate;

@property (nonatomic, strong) WDAllInvestor * allInvestor;

@end
