//
//  WDTopicDetailViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/22.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDTopicDetailViewController.h"
#import "WDHeaderForTopicDetailView.h"
#import "WDTopMainCell.h"
#import "WDTopCommentCell.h"
#import "UMSocial.h"


#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h> // 图片下载
#import "WDActivityDetalController.h"

#import "WDInfoTool.h"  //获取沙盒的登录信息

#import "WDTopicDetailModel.h" // 楼主的内容
#import "WDCommentModel.h"     // 评论的内容

#import "WDTopicButton.h" // 多一个tag
#import "WDCommentViewController.h" //回复页面

#import "TalkingData.h" // talkdata

#import "WDTopicShowCardViewController.h" // 小组卡片

#import "RootViewController.h" // 私信

#import "WDPersonalInfoViewController.h" // 查看别人的
#import "WDContentCellHeight.h"  // 记录没个评论的高度的模型


// 下面的本来是187 和 135  因为有些字只能显示出来一半 所以统一都加上21左右
#define KmainCellHeight 210
#define KContentCellHeight 160


@interface WDTopicDetailViewController ()<WDHeaderForTopicDetailViewDelegate,UMSocialUIDelegate>


//@property (assign ,nonatomic) CGFloat mainTextHeight;
//@property (assign ,nonatomic) BOOL isAdjustMainTextHeight;

//存放所有的留言
@property (strong, nonatomic) NSMutableArray *allMessageArr;
//存放评论的高度的高度；
@property (strong ,nonatomic) NSMutableArray * contentCellHeights;

//楼主的内容
@property (strong, nonatomic) WDTopicDetailModel * topicDetail;

@property (assign ,nonatomic) BOOL reloadLastRow;

//存放楼主的高度；
@property (assign ,nonatomic) CGFloat mainCellHeight;




@end

@implementation WDTopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
 //   self.isAdjustMainTextHeight = NO;
    self.reloadLastRow = NO; // 默认是不滚到最后一行的;

    // 接受评论的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successComment) name:@"successComment" object:nil];
    

    
    
    //
    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
//        // 下拉刷新
//        // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
//        self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            [weakSelf loadMoreData];
//        }];
    
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];

    
    
}



#pragma mark - 评论自动刷新
-(void)successComment{
    //获取话题详情  --- 重新刷一遍 然后自动滚到最下面;
  //  [self.allMessageArr addObject:[[WDCommentModel alloc] init] ];
    
    self.reloadLastRow = YES; // 默认是不滚到最后一行的; 需要滚到最后一

    
    [self getAllTopicConten];
    
    
}


#pragma mark - 懒加载所有评论信息
- (NSMutableArray *)allMessageArr{
    if (!_allMessageArr) {
        _allMessageArr = [NSMutableArray array];
    }
    return _allMessageArr;
}

#pragma mark - 评论信息者高度
- (NSMutableArray *)contentCellHeights{
    if (!_contentCellHeights) {
        _contentCellHeights = [NSMutableArray array];
    }
    return _contentCellHeights;
}





#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    //获取话题详情
    [self getAllTopicConten];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
    
}



#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    //获取话题详情
    [self getAllTopicConten];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
}




#pragma mark -\获取话题详情
-(void)getAllTopicConten{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
    // 首先要获得最上面的窗口
    // UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:self.view];
    
    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getDetailTalk";
    params[@"talk_id"] = self.topicModel.mID;
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];  // user_id可以为空;
    params[@"user_id"] = userID;

    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    
    [mgr GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"请求成功-getDetailTalk-%@", responseObject);
         //成功以后我就进度条
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         // 获得楼主的 信息
         NSDictionary * host = [[responseObject objectForKey:@"value"] firstObject];
         WDTopicDetailModel * topicDetail = [WDTopicDetailModel objectWithKeyValues:host];
         topicDetail.mGroupLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,topicDetail.mGroupLogo]; //所属于小组头像
         topicDetail.mLogo = [NSString stringWithFormat:@"%@%@",SERVER_URL,topicDetail.mLogo];   // 楼主头像
         
         
         // 把cell的高度计算出来
         self.mainCellHeight = [self adjustCellHeight:topicDetail.mTalkContent];
         
         self.topicDetail = topicDetail;
         
         // 获得评论的 信息
         [self.allMessageArr removeAllObjects];
         NSArray * arry = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"mTalkComments"];
         
         for (NSDictionary * dict in arry) {
             WDCommentModel * model = [WDCommentModel objectWithKeyValues:dict];
             model.mAvatar = [NSString stringWithFormat:@"%@%@",SERVER_URL,model.mAvatar];
             // 把cell的高度计算出来
             CGFloat cellHeight = [self adjustCellHeight:model.mTalkContent];
             WDContentCellHeight * height = [[WDContentCellHeight alloc] init];
             height.height = cellHeight;
             [self.contentCellHeights addObject:height];
             [self.allMessageArr addObject:model];
         }
         
         
         //         //成功
         //         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
         //             NSString * str = @"加载成功";
         //             [MBProgressHUD showSuccess:str];
         //
         //         }
         //失败
         
         if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
             NSString * str = @"还未添加小组";
             [MBProgressHUD showError:str];
         }
         
         
         // 成功了我就刷新tableview;
         [self.tableView reloadData];
         
         // 看下是否要滚到最后一行 因为如果是评论结束回来的了 就要滚到最后一行；
         if (self.reloadLastRow) {
             self.reloadLastRow = NO;
             NSIndexPath * path = [NSIndexPath indexPathForRow:self.allMessageArr.count-1  inSection:2];
             [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];

         }
         
         

         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // 请求失败的时候调用调用这个block
         NSLog(@"请求失败");
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showError:@"网络连接错误"];
     }];
    
}


- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    if (section == 1) return 1;
    return self.allMessageArr.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
// 卡片的组
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDShowCardCell" forIndexPath:indexPath];
        // 群头像
        UIButton * icon = [cell viewWithTag:21];
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        [downloader downloadImageWithURL:[NSURL URLWithString:self.topicDetail.mGroupLogo]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    // progression tracking code
                                }
                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                   if (image && finished) {
                                       // do something with image
                                image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(84, 84)];
                                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                                    
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           // 更UI
                                           [icon setBackgroundImage:image forState:UIControlStateNormal];

                                       });

                                   }
                               }];
        
        // 群名称
        UILabel * name = [cell viewWithTag:22];
        [name setText:self.topicDetail.mGroupName];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
    
// 楼主的组
    if (indexPath.section == 1) {
        WDTopMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDTopicCell" forIndexPath:indexPath];
#warning mark - 点赞的功能在cell里做 等下弄； 是否点赞 关键是看自己有没有登录 没有登录的 话都是没有。。。
        
        cell.mIsPraise = self.topicDetail.mIsPraise;
        cell.talk_id = self.topicDetail.mID;
        
        // 私信按钮
        WDTopicButton * btn =[cell viewWithTag:34];
        
        NSLog(@"---%@",[NSString stringWithFormat:@"%@",btn.class]);
        
        btn.mid = self.topicDetail.mUserID;
        [btn addTarget:self action:@selector(topicClickMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        // 点击评论按钮
        WDTopicButton * btnComment =[cell viewWithTag:39];
        NSString * userID = [WDInfoTool getLastAccountPlistUserID];
        btnComment.mid = userID;  // 当前用户的ID
        btnComment.talk_id = self.topicDetail.mID;  // 将要评论的话题的ID
        [btnComment addTarget:self action:@selector(topicClickbtnComment:) forControlEvents:UIControlEventTouchUpInside];

        // 话题标题
        UILabel * mTitle = [cell viewWithTag:31];
        [mTitle setText:self.topicDetail.mTitle];

        
        // 点击头像
        WDTopicButton * btnIcon = [[WDTopicButton alloc] init];
        [btnIcon setBackgroundImage:[UIImage imageNamed:@"default_120"] forState:UIControlStateNormal];  // 先清空头像，因为头像加载比较慢，这个以后改成占位图
        btnIcon = (WDTopicButton *)[cell viewWithTag:32];
        btnIcon.mid = userID;  // 当前用户的ID
        btnIcon.target_id = self.topicDetail.mUserID;  // 所点击的人的ID
        btnIcon.target_icoUrl = self.topicDetail.mLogo;  // 别人头像URl
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        [downloader downloadImageWithURL:[NSURL URLWithString:self.topicDetail.mLogo]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    // progression tracking code
                                }
                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                   if (image && finished) {
                                       // do something with image
                    image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(120, 120)];
                    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                                       
                    dispatch_async(dispatch_get_main_queue(), ^{
                                           // 更UI
                    [btnIcon setBackgroundImage:image forState:UIControlStateNormal];});
                                   }
                               }];
        [btnIcon addTarget:self action:@selector(topicClickIcon:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 发表话题人的名称
        UILabel * name = [cell viewWithTag:33];
        [name setText:self.topicDetail.mUserName];
        
        // 话题内容
        UITextView * mainText = (UITextView *)[cell viewWithTag:35];
        [mainText setText:self.topicDetail.mTalkContent];

        // 发表话题时间
        UILabel * time = [cell viewWithTag:36];
        [time setText:self.topicDetail.mCreateTime];

        //点赞次数
        UILabel * mPraiseCount = [cell viewWithTag:38];
        [mPraiseCount setText:self.topicDetail.mPraiseCount];
        
        //评论次数
        UILabel * mCommentCount = [cell viewWithTag:40];
        NSString * str = [NSString stringWithFormat:@"%lu",(unsigned long)self.allMessageArr.count];
        [mCommentCount setText:str];

        
       // 设置点赞的按钮
        UIButton * zan = [cell viewWithTag:37];
        if ([self.topicDetail.mIsPraise isEqualToString:@"0"]) { // 0未点赞 1是点赞
            [zan setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        }else{
            [zan setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
        }
        
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
// 评论者的组
    WDTopCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDTopicMessageCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewRowActionStyleNormal;
    
    WDCommentModel * model = self.allMessageArr[indexPath.row];
#warning mark - 点赞的功能在cell里做 等下弄； 是否点赞 关键是看自己有没有登录 没有登录的 话都是没有。。。
   
    cell.mIsPraise = model.mIsPraise;
    cell.talk_id = model.mTalkCommentID;

    
    // 设置头像
    WDTopicButton * btnIcon = [cell viewWithTag:51];
    [btnIcon setBackgroundImage:[UIImage imageNamed:@"default_120"] forState:UIControlStateNormal];  // 先清空头像，因为头像加载比较慢，这个以后改成占位图
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    btnIcon.mid = userID;  // 当前用户的ID
    btnIcon.target_id = model.mUserID ; // 当前评论的人得ID；
    btnIcon.target_icoUrl = model.mAvatar;  // 别人头像URl
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader downloadImageWithURL:[NSURL URLWithString:model.mAvatar]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                // progression tracking code
                            }
                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                               if (image && finished) {
                                   // do something with image
                                   image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(120, 120)];
                                   image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       // 更UI
                                       [btnIcon setBackgroundImage:image forState:UIControlStateNormal];});
                               }
                           }];

    [btnIcon addTarget:self action:@selector(topicClickIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    // 评论者的名称
    UILabel * name = [cell viewWithTag:52];
    [name setText:model.mNickName];
    
    // 评论者的楼层
    UILabel * orde = [cell viewWithTag:53];
    [orde setText:[NSString stringWithFormat:@"第%ld楼",indexPath.row + 1]];

    
    // 评论内容
    UITextView * mainText = [cell viewWithTag:54];
    [mainText setText:model.mTalkContent];
    
    // 评论的时间
    UILabel * time = [cell viewWithTag:55];
    [time setText:model.mCreateTime];
    
    //点赞次数
    UILabel * mPraiseCount = [cell viewWithTag:57];
    [mPraiseCount setText:model.mTalkCommentPraiseCount];
    
    // 设置点赞的按钮
    UIButton * zan = [cell viewWithTag:56];
    if ([model.mIsPraise isEqualToString:@"0"]) { // 0未点赞 1是点赞
        [zan setBackgroundImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
    }else{
        [zan setBackgroundImage:[UIImage imageNamed:@"zan2"] forState:UIControlStateNormal];
    }


    
    // Configure the cell...
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;


    
    
}

#pragma mark - 调整每个cell的高度;
-(CGFloat)adjustCellHeight:(NSString *)text{
    
    NSLog(@"[UIScreen mainScreen] bounds].size.width -%f",[[UIScreen mainScreen]bounds].size.width);
    
    CGFloat curWidth =  [[UIScreen mainScreen] bounds].size.width - 50-20;// 因为两边的空隙加起来是50，后面20防止字符刚好卡主了
    CGSize textMaxSize = CGSizeMake(curWidth, MAXFLOAT);
    CGSize textSize = [text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
    
    return textSize.height;
}



#pragma mark - 点了头像；
-(void)topicClickIcon:(WDTopicButton *)btn{
    
    NSLog(@"---%@ 点击了 %@的头像",btn.mid,btn.target_id);
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDPersonalInfoViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDPersonalInfoViewController"];
    
    controller.user_id = btn.mid;
    controller.target_id = btn.target_id;
    controller.target_iconUrl = btn.target_icoUrl;
    [self.navigationController pushViewController:controller animated:YES];

}




-(void)topicClickMessage:(WDTopicButton *)btn{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }
    RootViewController * controller = [[RootViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.tag_ID = @"66";
    controller.userID = userID;
    [self.navigationController pushViewController:controller animated:YES];
    
    

    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 60;
    }
    if (indexPath.section == 1) { // 楼主的cell;
        return self.mainCellHeight+KmainCellHeight;
    }
    // 评论的cell
    WDContentCellHeight * height = self.contentCellHeights[indexPath.row];
    return  height.height + KContentCellHeight;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView * whiteView = [cell viewWithTag:20];
        [whiteView setBackgroundColor:[UIColor grayColor]];
        
        [UIView animateWithDuration:0.2f animations:^{
            [whiteView setBackgroundColor:[UIColor whiteColor]];
        } completion:^(BOOL finished) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WDTopicShowCardViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDTopicShowCardViewController"];
            controller.topicDetail = self.topicDetail;
            [self.navigationController pushViewController:controller animated:YES];
            
        }];
    }
    if (indexPath.section == 1) {

        return;
    }
    
    
    if (indexPath.section == 1) {
        
        return;
    }

    
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UIView * whiteView = [cell viewWithTag:50];
//    UITextView * textView = (UITextView *)[cell viewWithTag:54];
//    [whiteView setBackgroundColor:[UIColor grayColor]];
//    [textView setBackgroundColor:[UIColor grayColor]];
//    
//    [UIView animateWithDuration:0.2f animations:^{
//        [whiteView setBackgroundColor:[UIColor whiteColor]];
//         [textView setBackgroundColor:[UIColor whiteColor]];
//    } completion:^(BOOL finished) {
    
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDTopicDetailViewController"];
//        [self.navigationController pushViewController:controller animated:YES];
        
  //  }];

}




-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        WDHeaderForTopicDetailView *view = [[[NSBundle mainBundle] loadNibNamed:@"WDHeaderForTopicDetailView" owner:nil options:nil] lastObject];
        view.delegate = self;
        return view;
    }
    return nil;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 55;
    }
    return 0;

}


#pragma mark - 点击话题回复按钮
-(void)WDTopicDetailSelectedreply{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录再参与评论"];
        return;
    }

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDCommentViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDCommentViewController"];
    controller.topicID = self.topicDetail.mID;
    [self.navigationController pushViewController:controller animated:YES];

    
}
#pragma mark - 友盟分享
-(void)WDTopicDetailSelectedtrans{
    NSString * str = [NSString stringWithFormat:@"%@\nwww.touwho.com/\n",self.topicDetail.mTitle];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5656cf55e0f55a0a7a000f56"
                                      shareText:str
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];

}

-(void)topicClickbtnComment:(WDTopicButton *) btn{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录再参与评论"];
        return;
    }
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WDCommentViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDCommentViewController"];
    controller.topicID = btn.talk_id;
    [self.navigationController pushViewController:controller animated:YES];

}





-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * str = [NSString stringWithFormat:@"话题-%@",self.topicDetail.mTitle];
    [TalkingData trackPageBegin:str];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"话题-%@",self.topicDetail.mTitle];
    [TalkingData trackPageEnd:str];
}


#pragma mark - 在系统调用dealloc的时候 把这个页面页面的观察者删除了
- (void)dealloc {
    NSLog(@"dealloc - 话题详情");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
