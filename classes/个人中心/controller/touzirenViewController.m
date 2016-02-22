//
//  touzirenViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/2.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "touzirenViewController.h"
#import "WDPickerView.h"
#import "WDTabBarController.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>



@interface touzirenViewController ()<UIScrollViewDelegate,UITextFieldDelegate,UITextViewDelegate,WDPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UITextView *comment; //文本框

@property (weak, nonatomic) IBOutlet UITextView *notes;

- (IBAction)checkButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *industryTF; //所属行业

@property (strong, nonatomic) NSString *industryValue;
@property (strong, nonatomic) WDPickerView *locatePicker;

- (IBAction)submit:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;




@end

@implementation touzirenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView.delegate = self;
    self.comment.delegate = self;
    
    // 设置申请框的边框；
    self.comment.layer.borderColor =  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0f].CGColor;

    self.comment.layer.borderWidth = 0.5;
    self.comment.layer.cornerRadius = 6;
    self.comment.layer.masksToBounds = YES;
    
    
    // 光标
    if(__IPHONE_9_0|__IPHONE_8_0 | __IPHONE_7_0){
        self.comment.tintColor=[UIColor blueColor];
    }
    
//    // 设置协议文本框的姿自适应；
//    CGSize currentSize = self.notes.frame.size;
//    CGSize textMaxSize = CGSizeMake(currentSize.width, MAXFLOAT);
//    CGSize textSize = [self.notes.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
//    self.notesHeight.constant = textSize.height + 50;
//    [self.notes layoutIfNeeded];
    
    
    
    self.industryTF.delegate = self;
    
    self.industryTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //监听回车；
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    
    // UITextFieldText开始编辑
    [center addObserver:self selector:@selector(textFiedTextBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    // UITextFieldText结束编辑
    [center addObserver:self selector:@selector(textFiedTextDidEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self cancelLocatePicker];
}


- (IBAction)checkButton:(id)sender {
    self.checkBtn.selected = !self.checkBtn.selected;
}

-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tabBar = (WDTabBarController *)self.tabBarController;
    tabBar.tabBar.hidden = YES;
    
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollView.transform =CGAffineTransformMakeTranslation(0,0);
    }];
    [self.view endEditing:YES];
    [self cancelLocatePicker];
}



-(void)setIndustryValue:(NSString *)industryValue{
    if (![_industryValue isEqualToString:industryValue]) {
        self.industryTF.text = industryValue;
    }
    
}

// 监听输入框
#pragma mark - textFied 通知
-(void)textFiedTextBeginEditing:(NSNotification *)noti{
    [self cancelLocatePicker];

}
#pragma mark - textView 代理；

////将要开始编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    [self cancelLocatePicker];
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollView.transform =CGAffineTransformMakeTranslation(0,-200);
    }];

    return YES;
}

////将要结束编辑
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
//    [UIView animateWithDuration:0.25f animations:^{
//        self.scrollView.transform =CGAffineTransformMakeTranslation(0,);
//    }];
//
//    return YES;
//}
//


#pragma mark - HZAreaPicker delegate
- (void)pickerDidChaneStatus:(WDPickerView *)picker;
{
    if(picker.pickerStyle == WDPickerStyle3ruzhudanwei)
    {
        self.industryValue = [NSString stringWithFormat:@"%@ %@ %@", picker.locate.industry1, picker.locate.industry2, picker.locate.industry3];
    }
    
    
    
}


-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}



#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f animations:^{
    self.scrollView.transform =CGAffineTransformMakeTranslation(0,-100);}];
    if ([textField isEqual:self.industryTF]){
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle3ruzhudanwei delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];
        return NO;  // 这样就不会弹出来键盘来了
    }
    return YES;  // 如果不是上面所选的 那么就弹出键盘；
}



- (IBAction)submit:(id)sender {
    if (self.comment.text ==nil || [self.comment.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入申请备注"];
        return;
    }
    if (self.industryTF.text ==nil || [self.industryTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请选择行业"];
        return;
    }

    
    if (!self.checkBtn.selected) {
        [MBProgressHUD showError:@"请勾选协议"];
        return;
    }
    
    [self uploadSet];
}




#pragma mark -上传
-(void)uploadSet{
    
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 声明：不要对服务器返回的数据进行解析，直接返回data即可
    // 如果是文件下载，肯定是用这个
    // responseObject的类型是NSData
    // mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    // mgr.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString * mID = self.mID;
    params[@"method"] = @"applicateFirstInvestor";
    params[@"user_id"] = mID;//
    params[@"destrible"] = self.comment.text;
    params[@"field1"] = self.industryTF.text;

    
    
    NSLog(@"请求之前 弄一下看一下这--%@",params);
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功---%@", responseObject);
        //缺少必要参数；
        
        NSString * resCode = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"];
        if ([resCode isEqualToString:@"0"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showSuccess:str];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败==%@",error);
        
        
    }];
    
    
}


@end
