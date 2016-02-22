//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "RootViewController.h"  // 新版语音
#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD+MJ.h"

#import "WDInfoTool.h"

#import "MBProgressHUD+MJ.h"



//#import "LeanMessageManager.h"  // leanCloud的工具类；

static NSInteger kPageSize = 5;


// 自定义属性来区分单聊和群聊

@interface RootViewController ()<UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate,AVIMClientDelegate>

//@property (strong, nonatomic) MJRefreshHeaderView *head;
@property (strong, nonatomic) ChatModel *chatModel;
@property (nonatomic, copy) NSString *selfClientID;
@property (nonatomic, strong) AVIMClient *imClient;


@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@property (nonatomic,strong) AVIMConversation *currentConversation;  //当前的会话；


//@property (strong , nonatomic) NSMutableArray * messages; // 储存服务器收到的聊天模型


//@property (strong ,nonatomic) NSData * voice; // 测试用得


//根据传过来的ID分别拉取头像和名字：
@property (copy,nonatomic) NSString *userIcon;
@property (copy,nonatomic) NSString *targetIcon;

@property (copy,nonatomic) NSString *userName;
@property (copy,nonatomic) NSString *targetName;



@end

@implementation RootViewController{
    UUInputFunctionView *IFView;
}

//#pragma mark - 懒加载聊天的数量；
//- (NSMutableArray *)allNewsArr{
//    if (!_messages) {
//        _messages = [NSMutableArray array];
//    }
//    return _messages;
//}
//



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"语音聊天"];
    
    // 创建了一个 client
    self.imClient = [AVIMClient defaultClient];
    
    // 设置 client 的 delegate，并实现 delegate 方法
    self.imClient.delegate = self;
    
    //UUchat 初始化聊天数组用的
    [self loadBaseViewsAndData];
    
    // 打开自己聊天--短信聊天；
    //  [self ReceiveMessageToTargetFromME:self.userID];
    
    // 下载自己的;
    [self settingMyinfo:self.userID];
    // 下载对方的
    [self settingTaginfo:self.tag_ID];

    
    // 打开自己的聊天短信；    ---- 并且 查询聊天记录；
    [self openSessionByClientId:self.userID navigationToIMWithTargetClientIDs:@[self.tag_ID]];
    
    
    // 每次进来后 自动下拉刷新；
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.chatTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.chatTableView.header beginRefreshing];
    
    
}

#pragma mark -  请求自己的名字和头像
-(void)settingMyinfo:(NSString *)mid{
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getMyInfo";
    params[@"user_id"] = mid;//
    
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
        
        // 设置图片的地址；
        self.userIcon = dict[@"mAvatar"];
        
        // 设置名字
        NSString * proname = [NSString stringWithFormat:@"%@",dict[@"mAccount"]];
        if (![dict[@"mNickName"] isEqualToString:@""]) {
            proname = [NSString stringWithFormat:@"%@",dict[@"mNickName"]];
        }
        self.userName = proname;
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        
        
    }];

}

#pragma mark -  请求对方的名字和头像
-(void)settingTaginfo:(NSString *)mid{
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getMyInfo";
    params[@"user_id"] = mid;//
    
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
        
        // 设置图片的地址；
        self.targetIcon = dict[@"mAvatar"];
        
        
        
        // NSLog(@"_image_image_image_image_image_image--%@",dict[@"mAvatar"]);
        
        // 设置名字
        NSString * proname = [NSString stringWithFormat:@"%@",dict[@"mAccount"]];
        if (![dict[@"mNickName"] isEqualToString:@""]) {
            proname = [NSString stringWithFormat:@"%@",dict[@"mNickName"]];
        }
        self.targetName = proname;
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        
        
    }];

}



// 设置当前对话
-(void)setCurrentConversation:(AVIMConversation *)currentConversation{
    _currentConversation = currentConversation;
}

//

#pragma mark - 这里是查询历史记录;
- (void)openSessionByClientId:(NSString*)clientId navigationToIMWithTargetClientIDs:(NSArray *)clientIDs {
    ///建立与leanCloud客户端的长连接
    [self openSessionWithClientID:clientId completion:^(BOOL succeeded, NSError *error) {
        
        if(!error){   // 如果没有错 那么就查询当前有的
            ///创建或者查询已有对话
            [self createConversationsWithClientIDs:clientIDs conversationType:1 completion:^(AVIMConversation *conversation, NSError *error) {
                NSLog(@"建立与leanCloud客户端的长连接-conversationId- %@",conversation.conversationId);
//                // 查询最近的 5 条聊天记录  kPageSize = 5
//                [conversation queryMessagesWithLimit:kPageSize callback:^(NSArray *objects, NSError *error) {
//                    // 刷新 Tabel 控件，为其添加数据源
////                    [self.messages addObjectsFromArray:objects];
////                    [self.messageTableView reloadData];
//                    //AVIMTypedMessage *firstMessage = self.messages[0];
//                    
//                    
//                    [self.messages addObjectsFromArray:objects];
//                    for (AVIMTypedMessage * Message in self.messages) {
//                        NSLog(@"这是我接收到历史消息---%@",Message.text);
//                    }
//
                // 从服务器端拉取
                     [conversation queryMessagesFromServerWithLimit:kPageSize callback:^(NSArray *objects, NSError *error) {
                    
                     //    NSLog(@"NSArray *objects -%@ -- NSError *error -%@ ",objects,error);
                         
              //      [self.messages addObjectsFromArray:objects];
                         
                         [self settingMes:objects];
                         
//                         
//                    for (AVIMTypedMessage * Message in objects) {
//                        NSLog(@"这是我接收到历史消息%@-谁发的%@-所属于的conID%@-消息的类型%hhd",Message.text,Message.clientId,Message.conversationId,Message.mediaType);}
                      }];
                
                if(error){
                    NSLog(@"从服务器端拉取-error%@",error);}
                }];
        }
            
                if(error){
                    NSLog(@"createConversationsWithClientIDs-error%@",error);}
            }];
}



#pragma mark - 接到历史记录后做的操作；
-(void)settingMes:(NSArray *)messages{
    
    for (AVIMTypedMessage * message in messages) {

        NSLog(@"这是我接收到历史消息%@-谁发的%@-所属于的conID%@-消息的类型%hhd",message.text,message.clientId,message.conversationId,message.mediaType);
        
        
        
        if (message.mediaType == kAVIMMessageMediaTypeText) {
            
            NSString * str = (NSString * )message.text;
            if([message.clientId isEqualToString:self.userID]){ // 说明是自己发得
                NSLog(@"kAVIMMessageMediaTypeText说明是自己发的");
                NSDictionary *dic = @{@"strContent": str,
                                      @"strName":self.userName,
                                      @"icon":self.userIcon,
                                      @"type": @(UUMessageTypeText)};
                [self dealTheFunctionData:dic];
                
            }else{
                NSDictionary *dic = @{@"strContent": str,
                                      @"strName":self.targetName,
                                      @"icon":self.targetIcon,
                                      @"type": @(UUMessageTypeText)};
                NSLog(@"kAVIMMessageMediaTypeText是别人发得");
               [self otherdealTheFunctionData:dic];
            }
        }
        
        
        if (message.mediaType == kAVIMMessageMediaTypeImage) {
            AVIMImageMessage *imageMessage = (AVIMImageMessage *)message;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 执行耗时的异步操作...
                UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageMessage.file.url]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 回到主线程，执行UI刷新操作
                    NSLog(@"kAVIMMessageMediaTypeImage-里开始处理信息 --%@",message.clientId);
                    
                    
                    if([message.clientId isEqualToString:self.userID]){ // 说明是自己发得
                        NSLog(@"kAVIMMessageMediaTypeImage说明是自己发的");
                        
                        NSDictionary *dic = @{@"picture": image,
                                              @"strName":self.userName,
                                              @"icon":self.userIcon,
                                              @"type": @(UUMessageTypePicture)};

                        [self dealTheFunctionData:dic];
 
                    }else{
                        NSLog(@"kAVIMMessageMediaTypeImage是别人发得");
                        
                        NSDictionary *dic = @{@"picture": image,
                                              @"strName":self.targetName,
                                              @"icon":self.targetIcon,
                                              @"type": @(UUMessageTypePicture)};

                    [self otherdealTheFunctionData:dic];

                    }
                });
            });
        }

        
        
        if (message.mediaType == kAVIMMessageMediaTypeAudio) {
            AVIMVideoMessage *videoMessage = (AVIMVideoMessage *)message;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 执行耗时的异步操作...
                NSLog(@"---videoMessage.file.url-%@",videoMessage.file.url);
                
                NSData * voice = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoMessage.file.url]];
                int second = videoMessage.duration;
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 回到主线程，执行UI刷新操作
                    if([message.clientId isEqualToString:self.userID]){ // 说明是自己发得
                        NSLog(@"kAVIMMessageMediaTypeAudio说明是自己发的");
                        NSDictionary *dic = @{@"voice": voice,
                                              @"strName":self.userName,
                                              @"icon":self.userIcon,
                                              @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                                              @"type": @(UUMessageTypeVoice)};

                        [self dealTheFunctionData:dic];

                    }else{
                        NSLog(@"kAVIMMessageMediaTypeAudio是别人发得");
                        NSDictionary *dic = @{@"voice": voice,
                                              @"strName":self.targetName,
                                              @"icon":self.targetIcon,
                                              @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                                              @"type": @(UUMessageTypeVoice)};

                       [self otherdealTheFunctionData:dic];
                    }
                    
                });
            });
    }


  }
}







///建立与leanCloud客户端的长连接
- (void)openSessionWithClientID:(NSString *)clientID
                     completion:(void (^)(BOOL succeeded, NSError *error))completion {
    self.selfClientID = clientID;
    if (self.imClient.status == AVIMClientStatusNone) {
        [self.imClient openWithClientId:clientID callback:completion];
    } else {
        [self.imClient closeWithCallback:^(BOOL succeeded, NSError *error) {
            [self.imClient openWithClientId:clientID callback:completion];
        }];
    }
}


///  如果打开后没有错 那么就 创建当前有的 创建或者查询已有对话
- (void)createConversationsWithClientIDs:(NSArray *)clientIDs
                        conversationType:(NSInteger)conversationType
                              completion:(AVIMConversationResultBlock)completion {
    NSMutableArray *targetClientIDs = [[NSMutableArray alloc] initWithArray:clientIDs];
    [targetClientIDs insertObject:self.selfClientID atIndex:0];
    [self createConversationsOnClientIDs:targetClientIDs conversationType:conversationType completion:completion];
}
- (void)createConversationsOnClientIDs:(NSArray *)clientIDs
                      conversationType:(int)conversationType
                            completion:(AVIMConversationResultBlock)completion {
    AVIMConversationQuery *query = [self.imClient conversationQuery];
    NSMutableArray *queryClientIDs = [[NSMutableArray alloc] initWithArray:clientIDs];
    //    [queryClientIDs insertObject:self.selfClientID atIndex:0];
    [query whereKey:kAVIMKeyMember containsAllObjectsInArray:queryClientIDs];
    [query whereKey:AVIMAttr(@"customConversationType") equalTo:[NSNumber numberWithInt:conversationType]];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        if (error) {
            // 出错了，请稍候重试
            completion(nil,error);
        } else if (!objects || [objects count] < 1) {
            // 新建一个对话
            [self.imClient createConversationWithName:nil
                                              clientIds:queryClientIDs
                                             attributes:@{@"customConversationType":[NSNumber numberWithInt:conversationType]}
                                                options:AVIMConversationOptionNone
                                               callback:completion];
        } else {
            
            // 已经有一个对话存在，继续在这一对话中聊天
            AVIMConversation *conversation = [objects lastObject];
            // 设置成当前；
            self.currentConversation =conversation;
            NSLog(@"// 已经有一个对话存在，继续在这一对话中聊天");
            completion(conversation,nil);
        }
    }];
}







//


#pragma mark - 下拉刷新后做的事情
- (void)loadNewData
{
//    /**
//     * 下拉 Table View 的时候，从服务端获取更多的消息记录。
//     */
//    if (self.messages.count == 0) {
//        // 拿到当前的下拉刷新控件，结束刷新状态
//        [self.chatTableView.header endRefreshing];
//        return;
//    } else {
//        AVIMTypedMessage *firstMessage = self.messages[0];
//        [self.currentConversation queryMessagesBeforeId:nil timestamp:firstMessage.sendTimestamp limit:kPageSize callback: ^(NSArray *objects, NSError *error) {
//
//            // 拿到当前的下拉刷新控件，结束刷新状态
//            [self.chatTableView.header endRefreshing];
//            
//            if (error == nil) {
//                NSInteger count = objects.count;
//                if (count == 0) {
//                    NSLog(@"no more old message");
//                } else {
//                    
//                    // 将更早的消息记录插入到 Tabel View 的顶部
//                    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
//                                           NSMakeRange(0,[objects count])];
//                    [self.messages insertObjects:objects atIndexes:indexes];
//                    [self.chatTableView reloadData];
//                }
//            }
//        }];
//    }
    
    // 拿到当前的下拉刷新控件，结束刷新状态
            [self.chatTableView.header endRefreshing];

}




#pragma mark - 这里是指发一条信息
- (void)sanendMessage:(NSString *)msg from:(NSString *)userID to:(NSString *)targetID {
    // Tom 创建了一个 client
   // self.imClient = [AVIMClient defaultClient];
    // Tom 用自己的名字作为 ClientId 打开 client
    [self.imClient openWithClientId:userID callback:^(BOOL succeeded, NSError *error) {
        
        ///创建或者查询已有对话  -- 这个创建就不是自己创建 而是把已有的找到 没有的话 再自己新建
        [self createConversationsWithClientIDs:@[targetID] conversationType:1 completion:^(AVIMConversation *conversation, NSError *error) {
            NSLog(@"--发送一条短信到网络-conversationId- %@",conversation.conversationId);
            
            // 设置成当前；
            self.currentConversation =conversation;
            NSLog(@"// 设置成当前");

            // 把我的信息弄成字典传过去
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            dict[@"userID"] = userID;
            dict[@"mNickName"] = [WDInfoTool userName]; // 获取当前用户的昵称
            
            AVIMTextMessage *message = [AVIMTextMessage messageWithText:msg attributes:dict];
            message.mediaType = kAVIMMessageMediaTypeText;
            [self.currentConversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"发送成功！");
                    
                    
                }
            }];
            
            if(error){
                NSLog(@"createConversationsWithClientIDs-error=%@",error);
                
            }
        }];
        
    }];
}

#pragma mark - 这里是指发一条图像
- (void)sanendImgaeMessage:(UIImage *)image From:(NSString *)userID to:(NSString *)targetID {
    // Tom 创建了一个 client
    // self.imClient = [AVIMClient defaultClient];
    // Tom 用自己的名字作为 ClientId 打开 client
    [self.imClient openWithClientId:userID callback:^(BOOL succeeded, NSError *error) {
        
        ///创建或者查询已有对话  -- 这个创建就不是自己创建 而是把已有的找到 没有的话 再自己新建
        [self createConversationsWithClientIDs:@[targetID] conversationType:1 completion:^(AVIMConversation *conversation, NSError *error) {
            NSLog(@"--发送一条短信到网络-conversationId- %@",conversation.conversationId);
            
            // 设置成当前；
            self.currentConversation =conversation;
            NSLog(@"// 设置成当前");
            
            // 把我的信息弄成字典传过去
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            dict[@"userID"] = userID;
            dict[@"mNickName"] = [WDInfoTool userName]; // 获取当前用户的昵称
            
            //AVFile *file的方法很多;  这里用直接传DATA的方法
            NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
            AVFile *file = [AVFile fileWithData:fileData];
            AVIMImageMessage *ImageMessage = [AVIMImageMessage messageWithText:nil file:file attributes:dict];
            ImageMessage.mediaType = kAVIMMessageMediaTypeImage;
            [conversation sendMessage:ImageMessage callback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"发送成功！");
                }
            }];
            
            if(error){
                NSLog(@"createConversationsWithClientIDs-error=%@",error);
                
            }
        }];
        
    }];
}




#pragma mark - 这里是指发一条语音
- (void)sanendVoiceMessgae:(NSString *)filePath time:(NSInteger)second From:(NSString *)userID to:(NSString *)targetID {
    // Tom 创建了一个 client
    // self.imClient = [AVIMClient defaultClient];
    // Tom 用自己的名字作为 ClientId 打开 client
    [self.imClient openWithClientId:userID callback:^(BOOL succeeded, NSError *error) {
        
        ///创建或者查询已有对话  -- 这个创建就不是自己创建 而是把已有的找到 没有的话 再自己新建
        [self createConversationsWithClientIDs:@[targetID] conversationType:1 completion:^(AVIMConversation *conversation, NSError *error) {
            NSLog(@"--发送一条短信到网络-conversationId- %@",conversation.conversationId);
            
            // 设置成当前；
            self.currentConversation =conversation;
            NSLog(@"// 设置成当前");
            
            // 把我的信息弄成字典传过去
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            dict[@"userID"] = userID;
            dict[@"mNickName"] = [WDInfoTool userName]; // 获取当前用户的昵称
            dict[@"strVoiceTime"] = [NSString stringWithFormat:@"%ld",(long)second]; // 视频有个秒数
            
            //AVFile *file的方法很多;  这里用直接传DATA的方法
///           NSData *fileData = voice;
//            AVFile *file = [AVFile fileWithData:fileData];
//
//            
//            NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//            NSString * plistPath = [caches stringByAppendingString:@"/voice"];
//
//            //先创建这个文件
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
//            // 文件正确位置
//            NSString *fileName = [plistPath stringByAppendingPathComponent:@"VoideMessages.mp3"];
//            
            
           // NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
             AVFile *file = [AVFile fileWithName:@"tmp" contentsAtPath:filePath];
            
            
            
           // AVFile * file = [AVFile fileWithData:voice];
            AVIMImageMessage *ImageMessage = [AVIMImageMessage messageWithText:nil file:file attributes:dict];
            ImageMessage.mediaType = kAVIMMessageMediaTypeAudio;
            
            
            [conversation sendMessage:ImageMessage callback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"发送成功！");
                }
            }];
            
            if(error){
                NSLog(@"createConversationsWithClientIDs-error=%@",error);
                
            }
        }];
        
    }];
}




#pragma mark - AVIMClientDelegate - didReceiveTypedMessage
// 接收消息的回调函数

/*!
 接收到新的富媒体消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 @return None.
 */

- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    NSLog(@"接收消息的回调函数-conversation--%@",conversation.conversationId);
    NSLog(@"每次都打印一下消息的类型--%hhd",message.mediaType);
    
    
    // 接到消息后 给前面的控制器发送一个通知
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    NSMutableDictionary * msg = [NSMutableDictionary dictionary];
    msg[@"message"] = message;
    [center postNotificationName:@"successMsg" object:self userInfo:msg];

    

    
//    if ([message.conversationId isEqualToString:self.currentConversation.conversationId]) {
////        [self.messages addObject:message];
////        [self.messageTableView reloadData];
//    }


// 接收全部的信息；
    NSDictionary * dict = message.attributes;
    NSLog(@"我:%@-收到一条ID:%@来自:%@-消息内容是:%@-message.conversationId:%@",self,dict[@"userID"],dict[@"mNickName"],message.text, message.conversationId);
    
    
// 这里分类开始处理信息
    if(message.mediaType == kAVIMMessageMediaTypeText){
        
        NSString * str = (NSString * )message.text;
        NSDictionary *dic = @{@"strContent": str,
                              @"strName":self.targetName,
                              @"icon":self.targetIcon,
                              @"type": @(UUMessageTypeText)};
        
        
        NSLog(@"kAVIMMessageMediaTypeText-里开始处理信息 --%@",message.clientId);
        
        [self otherdealTheFunctionData:dic];
    }
    
    if(message.mediaType == kAVIMMessageMediaTypeImage){
        
        AVIMImageMessage *imageMessage = (AVIMImageMessage *)message;
//        // 消息的 id
//        NSString *messageId = imageMessage.messageId;
//        //NSLog(@"-messageId----%@",messageId);
//        // 图像文件的 URL
//        NSString *imageUrl = imageMessage.file.url;
//        //NSLog(@"-imageUrl----%@",imageUrl);
//        // 发该消息的 ClientId
//        NSString *fromClientId = message.clientId;
//       // NSLog(@"-fromClientId----%@",fromClientId);
//
//        UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageMessage.file.url]]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 执行耗时的异步操作...
            UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageMessage.file.url]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 回到主线程，执行UI刷新操作
                
                NSDictionary *dic = @{@"picture": image,
                                      @"strName":self.targetName,
                                      @"icon":self.targetIcon,
                                      @"type": @(UUMessageTypePicture)};
                NSLog(@"kAVIMMessageMediaTypeImage-里开始处理信息 --%@",message.clientId);
                
                [self otherdealTheFunctionData:dic];

                
                
            });
        });

        
        
    }
    
    
    
    if(message.mediaType == kAVIMMessageMediaTypeAudio){
        
        AVIMVideoMessage *videoMessage = (AVIMVideoMessage *)message;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 执行耗时的异步操作...
            NSLog(@"---videoMessage.file.url-%@",videoMessage.file.url);
            
            NSData * voice = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoMessage.file.url]];
             NSLog(@"-----getData -%@",voice);
            
            int second = videoMessage.duration;

            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 回到主线程，执行UI刷新操作
                
                NSLog(@"-----%@",voice);
                NSDictionary *dic = @{@"voice": voice,
                                      @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                                      @"strName":self.targetName,
                                      @"icon":self.targetIcon,
                                      @"type": @(UUMessageTypeVoice)};
                
                NSLog(@"kAVIMMessageMediaTypeAudio-里开始处理信息 --%@",message.clientId);
                
                [self otherdealTheFunctionData:dic];

                
            });
        });

        
    }
    
}
#pragma mark - AVIMClientDelegate - didReceiveCommonMessage
/*!
 接收到新的普通消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 @return None.
 */
-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"收到新的消息" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [view show];
    
}


#pragma mark - AVIMClientDelegate - didReceiveUnread未读消息
/*
 收到未读通知。
 @param conversation 所属会话。
 @param unread 未读消息数量。
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread{
    NSLog(@"--name-%@--num-%ld",conversation.name,(long)unread);
    NSString * str = [NSString stringWithFormat:@"--name-%@--num-%ld",conversation.name,(long)unread];
    [MBProgressHUD showSuccess:str];
    
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
    
    
    // 刷新下tableView
    [self.chatTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark - UUChat初始化的设置
- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    [self.chatModel populateRandomDataSource];  // 初始化聊天数组用的
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - UUChat设置键盘
-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = keyboardEndFrame.size.height+40;
    }else{
        self.bottomConstraint.constant = 40;
    }
    
    [self.view layoutIfNeeded];
    
    //adjust UUInputFunctionView's originPoint
    CGRect newFrame = IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    
    NSLog(@"发了一条信息，内容是%@",message);
    
    
// 这里是发送一条信息
    [self sanendMessage:message from:self.userID to:self.tag_ID];
    
    NSDictionary *dic = @{@"strContent": message,
                          @"strName":self.userName,
                          @"icon":self.userIcon,
                          @"type": @(UUMessageTypeText)};
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    
// 这里是发送一个图片信息
    [self sanendImgaeMessage:image From:self.userID to:self.tag_ID];

    
    NSDictionary *dic = @{@"picture": image,
                          @"strName":self.userName,
                          @"icon":self.userIcon,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    

    
    NSString * caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString * plistPath = [caches stringByAppendingString:@"/voice"];
    //先创建这个文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    // 文件正确位置
    NSString *fileName = [plistPath stringByAppendingPathComponent:@"VoideMessages.mp3"];
       [voice writeToFile:fileName atomically:YES];
    // 这里发送一个语音；
    [self sanendVoiceMessgae:fileName time:second From:self.userID to:self.tag_ID];
    
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"strName":self.userName,
                          @"icon":self.userIcon,
                          @"type": @(UUMessageTypeVoice)};
    
    [self dealTheFunctionData:dic];
}


- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

- (void)otherdealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addOtherSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}






#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
//    // headIamgeIcon is clicked
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
//    [alert show];
}

@end
