//
//  WDCommunityTableViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/14.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDCommunityTableViewController.h"
#import "WDMenuButton.h"
#import "WDHeaderViewForCommunity.h"
#import "WDTabBarController.h"
#import "RootViewController.h"  // 新版语音

#import "MBProgressHUD+MJ.h"
#import "WDInfoTool.h"

#import "MJRefresh.h"

#import <AVOSCloud/AVOSCloud.h>
//如果使用了实时通信模块，请添加下列导入语句到头部：
#import <AVOSCloudIM.h>

#import "WDMsgListModel.h"  // 存放消息的模型


#import <AFNetworking.h>
#import <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>




@interface WDCommunityTableViewController ()<WDHeaderViewForCommunityDelegate,AVIMClientDelegate>


//@property(assign,nonatomic)int messageNum;

// @property (assign ,nonatomic) BOOL selectedNotification; 选项卡去掉了 合并了

@property (nonatomic, strong) AVIMClient *imClient;  // 新建一个客户端ID；

@property (nonatomic , strong) NSMutableArray * messages;


@end

@implementation WDCommunityTableViewController


#pragma mark -  懒加载
-(NSMutableArray *)messages{
    if (!_messages) {
        
        NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString * plistPath = [caches stringByAppendingString:@"/Plist"];
        NSString *fileName = [plistPath stringByAppendingPathComponent:@"messages.plist"];
        NSArray * array = [NSArray arrayWithContentsOfFile:fileName];

        if (array != nil&&array.count > 0) {
            _messages = [WDMsgListModel objectArrayWithKeyValuesArray:array];
        }else{
            _messages = [NSMutableArray array];
        }
        
    }
    return _messages;
}

#pragma mark -  懒加载imClient
-(AVIMClient *)imClient{
    if (!_imClient) {
        // 创建一个client
        _imClient = [AVIMClient defaultClient];
        // 设置 client 的 delegate，并实现 delegate 方法
        _imClient.delegate = self;
    }
    return _imClient;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
  //  self.messageNum = 5;
    
//    //  默认就是yes；这个是yes就会加载通知里的信息；
//    self.selectedNotification = YES;
    
    // 设置每一条的颜色为空
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    

    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
//    // 马上进入刷新状态
  [self.tableView.header beginRefreshing];

    
    
    
    // cell 设置好的通知;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successSETCell) name:@"successSETCell" object:nil];
   
    // 里面控制器发送了一条消息；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successMsg:) name:@"successMsg" object:nil];

    // 重新登录后 重新接受消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginReveiveMsg) name:@"loginReveiveMsg" object:nil];
    
    // 退出的通知 为的是把当前聊天信息都清空
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMsg) name:@"deleteMsg" object:nil];
    

    // 蒙版
    NSString * key = @"showPointView";
    NSString * lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (lastVersion == nil) {//
        //
        [self showPointView];
        [[NSUserDefaults standardUserDefaults] setObject:@"showPointView" forKey:@"showPointView"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}

#pragma mark - 登录后重新开启新的对话：
-(void)loginReveiveMsg{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {

        NSLog(@"还是没有登录成功");
        
    }else{
        // 如果我已经登录了 那么就用当前的登录的userId 打开了 client 并且一直接受消息；
        [self.imClient openWithClientId:userID callback:^(BOOL succeeded, NSError *error) {
            // ...
        }];

    }
}



-(void)deleteMsg{
    [self.messages removeAllObjects];
    
    NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    
    [self.imClient closeWithCallback:^(BOOL succeeded, NSError *error) {
        NSLog(@"之前账号的聊天已经关闭了");
    }];
}


-(void)showPointView{
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    UIButton * pointBtn =[[UIButton alloc] init];
    [pointBtn setAlpha:0.6f];
    [pointBtn setFrame:self.view.frame];
    [pointBtn addTarget:self action:@selector(clickPointView:) forControlEvents:UIControlEventTouchUpInside];
    [pointBtn setBackgroundColor:[UIColor blackColor]];
    
    
    //设置提示；
    UILabel * lable = [[UILabel alloc] initWithFrame:self.view.frame];
    [lable setText:@"给您发送的私信将会在这里接收"];
    [lable setFont:[UIFont systemFontOfSize:17]];
    [lable setTextAlignment:NSTextAlignmentCenter];
    [lable setTextColor:[UIColor whiteColor]];
    [pointBtn addSubview:lable];
    
    [window addSubview:pointBtn];
}

-(void)clickPointView:(UIButton*)btn{
    [btn removeFromSuperview];
}


-(void)successMsg:(NSNotification *)noti{
    NSDictionary * dict = noti.userInfo;
    AVIMTypedMessage * message = (AVIMTypedMessage *)dict[@"message"];
    
    WDMsgListModel * newModel = [[WDMsgListModel alloc] init];
    newModel.conversationId = message.conversationId;  // 先添加这个去看数组里有没有
    newModel.clientId = message.clientId;
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"M月d日 HH:mm"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    newModel.time = locationString;
    NSLog(@"从聊天界面接收成功--%@",locationString);
    
    if(message.mediaType == kAVIMMessageMediaTypeText){
        newModel.text = message.text;
    }
    
    if(message.mediaType == kAVIMMessageMediaTypeImage){
        newModel.text = @"[图片消息]";
    }
    
    if(message.mediaType == kAVIMMessageMediaTypeAudio){
        newModel.text = @"[语音消息]";
    }
    
    
    WDMsgListModel *tempModel = [[WDMsgListModel alloc] init];
    BOOL isExist = NO;
    // 如果以前有的话就删除
    for (WDMsgListModel * model in self.messages) {
        if ([model.conversationId isEqualToString:newModel.conversationId]) {
            //[self.messages removeObject:model];
            tempModel = model;
            isExist = YES;
        }
    }
    
    if (isExist) {
        [self.messages removeObject:tempModel];
    }
    
    [self.messages insertObject:newModel atIndex:0];
    
    
   NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
  [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    

    
    
    
}

#pragma mark - 刷新列表；
-(void)successSETCell{
        NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录,才能接收消息"];
        [self.tableView.header endRefreshing];
        
        NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString * plistPath = [caches stringByAppendingString:@"/Plist"];
        //先创建这个文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
        // 文件正确位置
        NSString *fileName = [plistPath stringByAppendingPathComponent:@"messages.plist"];
        NSArray * array = [NSArray arrayWithContentsOfFile:fileName];
        
        if(array == nil || array.count == 0){
            [self.messages removeAllObjects];
            NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
        
        return;
    }else{
        
        NSLog(@"现在开始接收消息了");

        
        
        
        // 如果我已经登录了 那么就用当前的登录的userId 打开了 client 并且一直接受消息；
        [self.imClient openWithClientId:userID callback:^(BOOL succeeded, NSError *error) {
            // ...
        }];

        
        
    }
    
    
//    // 每次都刷新一下tableview;
//    [self successSETCell];
    
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
    // });
}




// 接收消息的回调函数
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {

    WDMsgListModel * newModel = [[WDMsgListModel alloc] init];
//    newModel.name;
//    newModel.image;  设置clientId的时候都一起设置了

    newModel.conversationId = message.conversationId;  // 先添加这个去看数组里有没有
    newModel.clientId = message.clientId;  // name image 一起设置了
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"M月d日 HH:mm"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    newModel.time = locationString;
    NSLog(@"回调--%@",locationString);
    if(message.mediaType == kAVIMMessageMediaTypeText){
        newModel.text = message.text;
    }
    
    if(message.mediaType == kAVIMMessageMediaTypeImage){
        newModel.text = @"[图片消息]";
    }
    
    if(message.mediaType == kAVIMMessageMediaTypeAudio){
        newModel.text = @"[语音消息]";
    }
    
    
    
// 如果以前有的话就删除
    WDMsgListModel *tempModel = [[WDMsgListModel alloc] init];
    BOOL isExist = NO;
    for (WDMsgListModel * model in self.messages) {
        if ([model.conversationId isEqualToString:newModel.conversationId]) {
            //[self.messages removeObject:model];
            tempModel = model;
            isExist = YES;
        }
    }
    
    if (isExist) {
        [self.messages removeObject:tempModel];
    }
    
    [self.messages insertObject:newModel atIndex:0];

    NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return 1;
    return self.messages.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (indexPath.section == 0) {
       cell = [tableView dequeueReusableCellWithIdentifier:@"CommunityMenuCell" forIndexPath:indexPath];

        WDMenuButton * btn1 = (WDMenuButton *)[cell viewWithTag:21];
        // 设置按钮； 设置button如果没有forState  就没有效果了
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn1.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn1.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [btn1 addTarget:self action:@selector(selectedGroup) forControlEvents:UIControlEventTouchUpInside];
        
        //设置图片等比例显示
        [btn1.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn1 setImage:[UIImage imageNamed:@"communityXZ"] forState:UIControlStateNormal];
        [btn1 setTitle:@"小组" forState:UIControlStateNormal];
        
        WDMenuButton * btn2 = (WDMenuButton *)[cell viewWithTag:23];
        // 设置按钮； 设置button如果没有forState  就没有效果了
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn2.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn2.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [btn2 addTarget:self action:@selector(selectedZTJG) forControlEvents:UIControlEventTouchUpInside];
        //设置图片等比例显示
        [btn2.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn2 setImage:[UIImage imageNamed:@"communityJGZT"] forState:UIControlStateNormal];
        [btn2 setTitle:@"投资社区" forState:UIControlStateNormal];
        
        WDMenuButton * btn3 = (WDMenuButton *)[cell viewWithTag:22];
        // 设置按钮； 设置button如果没有forState  就没有效果了
        [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn3.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn3.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [btn3 addTarget:self action:@selector(selectedTopic) forControlEvents:UIControlEventTouchUpInside];
        
        //设置图片等比例显示
        [btn3.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn3 setImage:[UIImage imageNamed:@"communityZXHT"] forState:UIControlStateNormal];
        [btn3 setTitle:@"最新话题" forState:UIControlStateNormal];
        
        // 设置不可点击
        //cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // 这是第二组
    
    if(indexPath.section == 1 ){
        
        WDMsgListModel * model = self.messages[indexPath.row];
        
        NSLog(@"WDMsgListModel-%@-%@-%@-%@-%@",model.image,model.name,model.time,model.conversationId,model.clientId);
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"WDMessageCell" forIndexPath:indexPath];
        
        UIImageView * image = [cell viewWithTag:41];
        [image sd_setImageWithURL:[NSURL URLWithString:model.image]];
        
        NSLog(@"image-url--%@",model.image);
        
        UILabel * name = [cell viewWithTag:42];
        [name setText:model.name];
        
        UILabel * text = [cell viewWithTag:43];
        [text setText:model.text];
        
        UILabel * time  = [cell viewWithTag:44];
        [time setText:model.time];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        
    }
    

    return cell;
}



-(void)selectedZTJG{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDJGZTViewController"];
    controller.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:controller animated:YES];

    
}


-(void)selectedTopic{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDNewTopicViewContorller"];
    controller.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:controller animated:YES];

    
}


-(void)selectedGroup{

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"WDGroupViewController"];
    controller.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:controller animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) return 120;
    return 80;
}



#pragma mark 下面的是代理实现的方法；
#pragma mark 当用户提交了一个编辑操作就会调用这个
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle != UITableViewCellEditingStyleDelete) return;//如果不是删除模式那么就返回；删除模式是默认的；
    // 1. 删除模型数据；
    
    WDMsgListModel * model = self.messages[indexPath.row];
    [self.messages removeObject:model];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark 进入编辑
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) return 40;
    return 0;

}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        WDHeaderViewForCommunity * Headerview  = [[[NSBundle mainBundle] loadNibNamed:@"WDHeaderViewForCommunityNew" owner:nil options:nil] lastObject];
        return Headerview;
    }
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1 ){
    
        WDMsgListModel * mode = self.messages[indexPath.row];
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView * whiteView = [cell viewWithTag:20];
        [whiteView setBackgroundColor:[UIColor grayColor]];
        [UIView animateWithDuration:0.25f animations:^{
            [whiteView setBackgroundColor:[UIColor whiteColor]];
        } completion:^(BOOL finished) {

            NSString * userID = [WDInfoTool getLastAccountPlistUserID];
            if ([userID isEqualToString:@""] || userID ==nil) {
                [MBProgressHUD showError:@"请先登录"];
                return;
            }
            RootViewController * controller = [[RootViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
#pragma  mark - 这里先写死
            controller.tag_ID = mode.clientId;
            controller.userID = userID;
            [self.navigationController pushViewController:controller animated:YES];
            
        }];
        
    }
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tab = (WDTabBarController *)self.tabBarController;
    if (tab.tabBar.hidden == YES) {
        tab.tabBar.hidden = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    // 马上进入刷新状态  每次这个页面要显示 我都刷新一下
//    [self.tableView.header beginRefreshing];
    
    // 每次都刷新一下tableview;
    [self successSETCell];


}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"---------完全退出了社群的首页-------------");
    
    
    NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString * plistPath = [caches stringByAppendingString:@"/Plist"];
    //先创建这个文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    // 文件正确位置
    NSString *fileName = [plistPath stringByAppendingPathComponent:@"messages.plist"];

    
    if (self.messages.count>0) {
        // 通过一个模型数组来变成一个字典模型
        NSArray * messageArr  = [WDMsgListModel keyValuesArrayWithObjectArray:self.messages];
        
        [messageArr writeToFile:fileName atomically:YES];
    }else{
        [fileManager removeItemAtPath:fileName error:nil];
    }
    
    
}

#pragma mark - 在系统调用dealloc的时候 把这个页面页面的观察者删除了
- (void)dealloc {
    NSLog(@"dealloc - 社群主页");

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
