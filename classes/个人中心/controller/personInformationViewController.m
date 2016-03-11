//
//  personInformationViewController.m
//  ad
//
//  Created by apple on 15/7/27.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "personInformationViewController.h"
#import <MobileCoreServices/MobileCoreServices.h> // 摄像头
#import "WDTabBarController.h"
#import "WDPickerView.h"
#import "WDMyInfo.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "WDInfoTool.h"

#import <MJExtension.h> // 字典转模型



@interface personInformationViewController ()<UITextFieldDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,WDPickerViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *realName; // 真实姓名
@property (weak, nonatomic) IBOutlet UITextField *number;// 手机号码
@property (weak, nonatomic) IBOutlet UITextField *identityCard;// 身份证号码
@property (weak, nonatomic) IBOutlet UITextField *nickName;// 昵称
@property (weak, nonatomic) IBOutlet UITextField *mail;// 邮箱地址
@property (weak, nonatomic) IBOutlet UITextField *qqNum;// qq
@property (weak, nonatomic) IBOutlet UITextField *weChatNum;// 微信

- (IBAction)upLoadingBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *cardImage;  // 名片
@property (assign,nonatomic) BOOL cardImageSelected; //记录是否有选新的图片

@property (weak, nonatomic) IBOutlet UITextView *touzilinian;  // 投资理念


@property (weak, nonatomic) IBOutlet UIButton *sexMaleBtn;
@property (weak, nonatomic) IBOutlet UIButton *sexLadyBtn;
@property (assign ,nonatomic)BOOL selectMale;
@property (assign ,nonatomic)BOOL selectLady;
- (IBAction)maleBtn:(UIButton *)sender;
- (IBAction)ladyBtn:(UIButton *)sender;

- (IBAction)maleButton:(UIButton *)sender;
- (IBAction)ladyButton:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewTopH;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

//
@property (weak, nonatomic) IBOutlet UITextField *ageTF; // 年龄
@property (weak, nonatomic) IBOutlet UITextField *suochuhangyeTF; //所处行业
@property (weak, nonatomic) IBOutlet UITextField *gangxinquehangyeTF; // 感兴趣行业
@property (weak, nonatomic) IBOutlet UITextField *fenxiangpianhaoTF;  // 风险偏好

@property (strong, nonatomic) NSString *ageT; // 年龄
@property (strong, nonatomic) NSString *suochuhangyeT; //所处行业
@property (strong, nonatomic) NSString *gangxinquehangyeT; // 感兴趣行业
@property (strong, nonatomic) NSString *fenxiangpianhaoT;  // 风险偏好

@property (strong, nonatomic) WDPickerView *locatePicker;

// 适配5屏幕
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexLeftConstraint;  // 41
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameRightConstraint;   // 50
@property (weak, nonatomic) IBOutlet UIButton *gudingWZBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gudingWZBtnLConstraint;  // 177
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gudingWZBtnRConstraint;  // 177

// 提交按钮
- (IBAction)submit:(id)sender;

@end

@implementation personInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化文本框
    [self settingTextView];
    

    // 键盘的通知
    // 通知中心 在这里；  监听键盘；
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter]; //单例；
    // 监听 监听者 ；添加监听者；
    // [center addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // UITextFieldText开始编辑
    [center addObserver:self selector:@selector(textFiedTextBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    // UITextFieldText结束编辑
    [center addObserver:self selector:@selector(textFiedTextDidEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    //
    self.cardImage.layer.masksToBounds = YES;
    self.cardImage.layer.cornerRadius = 6.0;
    self.cardImage.layer.borderWidth = 1.0;
    self.cardImage.layer.borderColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0f].CGColor;
    
    //初始化性别
    self.selectLady = NO;
    self.selectMale = YES;
    NSLog(@"现在选着的性别是--男%@-女%@",self.selectMale?@"YES":@"NO",self.selectLady?@"YES":@"NO");
    
    // 适配5的屏幕更新约束
    [self just5];
    
    // 把已经获取到得设置
    [self settingTextViewValue];
    
    
    // -用来判断有没有设置过明信片；
    self.cardImageSelected = NO;
    
    // 设置投资理念的框
    self.touzilinian.delegate = self;
    // 设置投资理念框；
    self.touzilinian.layer.borderColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0f].CGColor;
    
    self.touzilinian.layer.borderWidth = 0.5;
    self.touzilinian.layer.cornerRadius= 6.0;
    self.touzilinian.layer.masksToBounds = YES;
    
    // 光标
    if(__IPHONE_9_0|__IPHONE_8_0 | __IPHONE_7_0){
        self.touzilinian.tintColor=[UIColor blueColor];
    }

}

#pragma mark - 设置基本的信息
-(void)settingTextViewValue{
    NSDictionary * dict = [WDInfoTool getLastAccountPlist];
    WDMyInfo * myInfo = [WDMyInfo objectWithKeyValues:dict];
    
    // 性别
    if ([myInfo.mSex isEqualToString:@"1"]) { //女生
        [self.sexLadyBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else{//男生；
        [self.sexMaleBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    //真实姓名；
    self.realName.text = myInfo.mName;
    
    //手机号码；
    self.number.text = myInfo.mPhone;
    
    //身份证号；
    self.identityCard.text = myInfo.mIDCardCode;
    
    // 用户昵称；
    self.nickName.text = myInfo.mNickName;
    
    //用户邮箱
    self.mail.text = myInfo.mEmail;
  
    //年龄
    self.ageTF.text = myInfo.mAge;
    
    //所属行业
    self.suochuhangyeTF.text = myInfo.mIndustry;
    
    //感兴趣行业
    self.gangxinquehangyeTF.text = myInfo.mFavIndustry;
    
    //风险偏好
    self.fenxiangpianhaoTF.text = myInfo.mFav;
    
    //QQ
    self.qqNum.text = myInfo.mQQ;
    
    //微信
    self.weChatNum.text = myInfo.mWeiXin;
    
    //投资理念
    self.touzilinian.text = myInfo.mDes;
    
    
   //设置名片
    if (![myInfo.mCardUrl isEqualToString:@""]) {
        NSLog(@"yInfo.mCardUrl isEqualToStrin");
        [self.cardImage sd_setImageWithURL:[NSURL URLWithString:myInfo.mCardUrl]];
    }
    
}

#pragma mark -初始化文本框
-(void)settingTextView{
    
    self.scrollview.backgroundColor = [UIColor colorWithRed:139 green:139 blue:139 alpha:1];
    self.scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 设置代理
    self.realName.delegate = self;
    self.number.delegate = self;
    self.identityCard.delegate = self;
    self.nickName.delegate = self;
    self.mail.delegate = self;
    self.qqNum.delegate = self;
    self.weChatNum.delegate = self;
    
    self.ageTF.delegate = self;
    self.suochuhangyeTF.delegate =self;
    self.gangxinquehangyeTF.delegate =self;
    self.fenxiangpianhaoTF.delegate = self;
    
    //scrollView的代理；
    self.scrollview.delegate = self;
    
    // 光标
    if(__IPHONE_8_0 | __IPHONE_7_0){
        self.realName.tintColor=[UIColor blueColor];
        self.number.tintColor=[UIColor blueColor];
        self.identityCard.tintColor=[UIColor blueColor];
        self.nickName.tintColor=[UIColor blueColor];
        self.mail.tintColor=[UIColor blueColor];
        self.qqNum.tintColor=[UIColor blueColor];
        self.weChatNum.tintColor=[UIColor blueColor];
    }
    
    
    // 设置文本框对齐方式
    self.realName.leftViewMode = UITextFieldViewModeAlways;
    self.number.leftViewMode = UITextFieldViewModeAlways;
    self.identityCard.leftViewMode = UITextFieldViewModeAlways;
    self.nickName.leftViewMode = UITextFieldViewModeAlways;
    self.mail.leftViewMode = UITextFieldViewModeAlways;
    self.qqNum.leftViewMode = UITextFieldViewModeAlways;
    self.weChatNum.leftViewMode = UITextFieldViewModeAlways;
    
    // 右边的叉叉
    self.realName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.number.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.identityCard.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nickName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.mail.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.qqNum.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.weChatNum.clearButtonMode = UITextFieldViewModeWhileEditing;
    

}

#pragma mark - 适配5屏幕
-(void)just5{
    
    
    if ([[UIScreen mainScreen] bounds].size.width < 375) {
        
        // 更改姓名的约束   41
        self.sexLeftConstraint.constant = 10;
        [self.sexLabel layoutIfNeeded];
        
        // 更改文本框的约束 50
        self.nameRightConstraint.constant = 10;
        [self.realName layoutIfNeeded];
        
        
        // 更改固定位置按钮左，右两边的约束； 177
        self.gudingWZBtnLConstraint.constant = 137;
        self.gudingWZBtnRConstraint.constant = 137;
        
        [self.gudingWZBtn layoutIfNeeded];
        
        
    }

}


-(void)setAgeT:(NSString *)ageT{
    if (![_ageT isEqualToString:ageT]) {
        self.ageTF.text = ageT;
    }
}

-(void)setSuochuhangyeT:(NSString *)suochuhangyeT{
    if (![_suochuhangyeT isEqualToString:suochuhangyeT]) {
        self.suochuhangyeTF.text = suochuhangyeT;
    }

}

-(void)setGangxinquehangyeT:(NSString *)gangxinquehangyeT{
    if (![_gangxinquehangyeT isEqualToString:gangxinquehangyeT]) {
        self.gangxinquehangyeTF.text = gangxinquehangyeT;
    }
}

-(void)setFenxiangpianhaoT:(NSString *)fenxiangpianhaoT{
    if (![_fenxiangpianhaoT isEqualToString:fenxiangpianhaoT]) {
        self.fenxiangpianhaoTF.text = fenxiangpianhaoT;
    }
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark  - send TextField的代理方法; 点击右下角的send按钮、、
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollview.transform =CGAffineTransformMakeTranslation(0,0);
    }];

    return YES;  // 直接给一个yes;
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollview.transform =CGAffineTransformMakeTranslation(0,0);
        self.view.transform =CGAffineTransformMakeTranslation(0,0);

    }];

    [self.view endEditing:YES];
    
    NSLog(@"---scrollViewWillBeginDragging-x-%f",scrollView.contentOffset.x);
    NSLog(@"---scrollViewWillBeginDragging-y-%f",scrollView.contentOffset.y);


    
    [self cancelLocatePicker];
}




- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollview.transform =CGAffineTransformMakeTranslation(0,0);
    }];

    [self.view endEditing:YES];
        
}






//#pragma mark - 监听键盘
//// 监听成功后 会调用的方法；
//-(void)keyboardDidChangeFrame:(NSNotification *)noti{
////            // transform 平移缩放；
////        CGRect frame=[noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
////        CGFloat screenH = [[UIScreen mainScreen] bounds].size.height; // 屏幕高度；
////        CGFloat keyY =frame.origin.y;   // 键盘的实时Y。
////        CGFloat keyDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]; //KEYB的持续时间
////        [UIView animateWithDuration:keyDuration animations:^{
////            self.scrollView.transform =CGAffineTransformMakeTranslation(0, keyY - screenH);  // 这个是大View
////        }];
////        
////        
//
//}






-(void)viewWillAppear:(BOOL)animated{
    WDTabBarController * tabBar = (WDTabBarController *)self.tabBarController;
    tabBar.tabBar.hidden = YES;
    

}




-(void)textFiedTextDidEditing:(NSNotification *)noti{
    [UIView animateWithDuration:0.25f animations:^{
        self.scrollview.transform =CGAffineTransformMakeTranslation(0,0);
        self.view.transform =CGAffineTransformMakeTranslation(0,0);

     }];
}




- (IBAction)upLoadingBtn:(UIButton *)sender {
     [self.view endEditing:YES];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];

    
    [sheet showInView:self.view.window];

}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"dfdsjfkjdsfjksdhk---%ld",(long)buttonIndex);
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    
    
    ipc.mediaTypes = @[(NSString *)kUTTypeImage];
    ipc.allowsEditing = YES;
    
    // 设置代理
    ipc.delegate = self;
    
    switch (buttonIndex) {
        case 0: { // 拍照
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        }
        case 1: { // 相册
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
            ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        default:
            break;
    }
    
    // 显示控制器
    if(buttonIndex ==0 || buttonIndex==1){
        [self presentViewController:ipc animated:YES completion:nil];
    }
}




#pragma mark - UIImagePickerControllerDelegate
/**
 *  在选择完图片后调用
 *
 *  @param info   里面包含了图片信息
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 获得图片
//    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage * image = info[UIImagePickerControllerEditedImage]; // 最后选中的图片
    if(!image){
        image = info[UIImagePickerControllerOriginalImage];
    }

    
    // 这里先显示成 压缩后的
    image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(300, 300)];
    
    
    // 显示图片
    self.cardImage.image = image;
    self.cardImageSelected = YES; // 因为改变了图片，说明设置了新的图；
}


//  压缩成PNG格式
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



- (IBAction)maleBtn:(UIButton *)sender {
    if (self.selectMale == NO) {
        self.selectMale = YES;   // 记录最后一次点击的选择
        self.selectLady = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"sexSelected"] forState:UIControlStateNormal];
        [self.sexLadyBtn setBackgroundImage:[UIImage imageNamed:@"sexNormal"] forState:UIControlStateNormal];
    }
    
    NSLog(@"现在选着的性别是--男%@-女%@",self.selectMale?@"YES":@"NO",self.selectLady?@"YES":@"NO");
    
}

- (IBAction)ladyBtn:(UIButton *)sender {
    if (self.selectLady == NO) {
        self.selectLady = YES;   // 记录最后一次点击的选择
        self.selectMale = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"sexSelected"] forState:UIControlStateNormal];
        [self.sexMaleBtn setBackgroundImage:[UIImage imageNamed:@"sexNormal"] forState:UIControlStateNormal];
    }
    
    NSLog(@"现在选着的性别是--男%@-女%@",self.selectMale?@"YES":@"NO",self.selectLady?@"YES":@"NO");

}

- (IBAction)maleButton:(UIButton *)sender {
    if (self.selectMale == NO) {
        self.selectMale = YES;   // 记录最后一次点击的选择
        self.selectLady = NO;
        [self.sexMaleBtn setBackgroundImage:[UIImage imageNamed:@"sexSelected"] forState:UIControlStateNormal];
        [self.sexLadyBtn setBackgroundImage:[UIImage imageNamed:@"sexNormal"] forState:UIControlStateNormal];
    }
    
    NSLog(@"现在选着的性别是--男%@-女%@",self.selectMale?@"YES":@"NO",self.selectLady?@"YES":@"NO");

}

- (IBAction)ladyButton:(UIButton *)sender {
    if (self.selectLady == NO) {
        self.selectLady = YES;   // 记录最后一次点击的选择
        self.selectMale = NO;
        [self.sexLadyBtn setBackgroundImage:[UIImage imageNamed:@"sexSelected"] forState:UIControlStateNormal];
        [self.sexMaleBtn setBackgroundImage:[UIImage imageNamed:@"sexNormal"] forState:UIControlStateNormal];
    }
    
    NSLog(@"现在选着的性别是--男%@-女%@",self.selectMale?@"YES":@"NO",self.selectLady?@"YES":@"NO");

}



#pragma  mark - pickerviEW;



#pragma mark - HZAreaPicker delegate



-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}


#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    
    [self cancelLocatePicker];

    
    if ([textField isEqual:self.ageTF]) {
        
//        [UIView animateWithDuration:0.25f animations:^{
//            self.scrollView.transform =CGAffineTransformMakeTranslation(0, 0);
//        }];
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        // 这里初始化，这里开始执行调用；// 把代理传进去
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle1age delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];// 这里显示
        
        return NO;  // 这样就不会弹出来键盘来了

        
    }
    
    
    if ([textField isEqual:self.suochuhangyeTF]) {
        
        [UIView animateWithDuration:0.25f animations:^{
            self.scrollview.transform =CGAffineTransformMakeTranslation(0, -50);
        }];

        
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        // 这里初始化，这里开始执行调用；// 把代理传进去
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle1suochuhangye delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];// 这里显示
        
        return NO;  // 这样就不会弹出来键盘来了

    }

    
    
    if ([textField isEqual:self.gangxinquehangyeTF]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.scrollview.transform =CGAffineTransformMakeTranslation(0, -100);
        }];

        
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        // 这里初始化，这里开始执行调用；// 把代理传进去
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle1ganxingquehangye delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];// 这里显示
        return NO;  // 这样就不会弹出来键盘来了

        
    }
    
    if ([textField isEqual:self.fenxiangpianhaoTF]) {
        [UIView animateWithDuration:0.25f animations:^{
            self.scrollview.transform =CGAffineTransformMakeTranslation(0, -150);
        }];

        
        [self cancelLocatePicker];
        [self.view endEditing:YES];
        // 这里初始化，这里开始执行调用；// 把代理传进去
        self.locatePicker = [[WDPickerView alloc] initWithStyle:WDPickerStyle1fengxianpianhao delegate:self];//把代理传进去
        [self.locatePicker showInView:self.view];// 这里显示
        return NO;  // 这样就不会弹出来键盘来了

        
    }

    return YES;  //如果不是上面所选 键盘弹出来
}


-(void)textFiedTextBeginEditing:(NSNotification *)noti{
    
        [self cancelLocatePicker];
    
    if ([noti.object isEqual:self.nickName]) {
        if (self.scrollview.contentOffset.y > 152) {return;}

        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -200);
        }];
    }
    
    if ([noti.object isEqual:self.mail]) {
        if (self.scrollview.contentOffset.y > 166) {return;}

        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -200);
        }];
    }
    
    if ([noti.object isEqual:self.qqNum]) {
        if (self.scrollview.contentOffset.y > 210) {return;}

        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -200);
        }];
    }
    
    if ([noti.object isEqual:self.weChatNum]) {
        if (self.scrollview.contentOffset.y > 318) {return;}

        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, -200);
        }];
    }
    
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.scrollview.contentOffset.y > 318) {return YES;}
    
    if (self.scrollview.contentOffset.y < 109) {
        
        [UIView animateWithDuration:0.25f animations:^{
           // self.view.transform =CGAffineTransformMakeTranslation(0, -400);
            //scrollview 设置滑动
            self.scrollview.contentOffset = CGPointMake(0, 318);
        }];

        return YES;}

    
    [UIView animateWithDuration:0.25f animations:^{
        self.view.transform =CGAffineTransformMakeTranslation(0, -200);
    }];

    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}


- (void)pickerDidChaneStatus:(WDPickerView *)picker;
{
    if (picker.pickerStyle == WDPickerStyle1age) {
        self.ageT = [NSString stringWithFormat:@"%@", picker.locate.age];
    }
    
    if (picker.pickerStyle == WDPickerStyle1suochuhangye) {
        self.suochuhangyeT = [NSString stringWithFormat:@"%@", picker.locate.suochuhangye];
    }
    if (picker.pickerStyle == WDPickerStyle1ganxingquehangye) {
        self.gangxinquehangyeT = [NSString stringWithFormat:@"%@", picker.locate.ganxingquhangye];
    }
    
    if (picker.pickerStyle == WDPickerStyle1fengxianpianhao) {
        self.fenxiangpianhaoT = [NSString stringWithFormat:@"%@", picker.locate.fengxianpianhao];
    }
    
}


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//
//    // 退出编辑模式 ，然后退出滚动旋转；
//    [self.view endEditing:YES];
//    [UIView animateWithDuration:0.25f animations:^{
//        self.view.transform =CGAffineTransformMakeTranslation(0,0);
//    }];
//    
//    
//    [self cancelLocatePicker];
//
//}

#pragma mark - 提交按钮
- (IBAction)submit:(id)sender {
    NSLog(@"提交按钮");
    
    if (self.realName.text ==nil || [self.realName.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入真实姓名"];
        return;
    }
    if (self.number.text ==nil || [self.number.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入手机号码"];
        return;
    }
    if (self.number.text.length != 11) {
        [MBProgressHUD showError:@"手机号码长度有误"];
        return;
    }
    
    if (self.ageTF.text ==nil || [self.ageTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入年龄"];
        return;
    }
    if (self.suochuhangyeTF.text ==nil || [self.suochuhangyeTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入所属行业"];
        return;
    }
    if (self.gangxinquehangyeTF.text ==nil || [self.gangxinquehangyeTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入感兴趣行业"];
        return;
    }
    if (self.fenxiangpianhaoTF.text ==nil || [self.fenxiangpianhaoTF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入风险偏好"];
        return;
    }

    
    
    
    // 开始上传
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
    
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:window];

    
    
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"setMyInfo";
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    params[@"user_id"] = userID;
    params[@"sex"] = self.selectMale?@"2":@"1";//性别 1女2男
    params[@"name"] = self.realName.text;//姓名
    params[@"phone"] = self.number.text;//手机号码
    params[@"id_code"] = self.identityCard.text;//身份证
    params[@"nick_name"] = self.nickName.text;//昵称
    params[@"email"] = self.mail.text;//邮箱

    params[@"age"] = self.ageTF.text;//年龄
    params[@"industry"] = self.suochuhangyeTF.text;//所属行业
    params[@"favIndustry"] = self.gangxinquehangyeTF.text;//感兴趣行业
    params[@"fav"] = self.fenxiangpianhaoTF.text;//风险偏好
    params[@"qq"] = self.qqNum.text;//QQ
    params[@"weixin"] = self.weChatNum.text;//微信
    params[@"des"] = self.touzilinian.text;//投资理念


    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";

    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功---%@", responseObject);
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];

        
        
        if (self.cardImageSelected) {
            [self upload:self.cardImage.image];
            
        }else{
            
            //成功
            if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
                NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
                [MBProgressHUD showSuccess:str];
                
                
            }

            // 最后来根据这个ID下载最新的信息 以免在其他客户端改变了东西没有及时改过来  - 只下载 不设置
            [self uploadNewInfo:userID];

            

            // 成功后发送一个通知
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            dict[@"newName"] = self.nickName.text;
//            if ([self.nickName.text isEqualToString:@""]) {
//              dict[@"newName"] = self.number.text;
//            }
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"successSETInfo" object:self userInfo:dict];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        

    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        // 请求失败的时候调用调用这个block
        NSLog(@"登录失败---%@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"设置失败"];
    }];
    
    
}


#pragma mark - 上传身份证；
- (void)upload:(UIImage *)image
{
    // 1.创建一个管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    //设置管理者
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [mgr.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    // 2.封装参数(这个字典只能放非文件参数)
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"uploadCard";
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    params[@"user_id"] = userID;
    
    // 2.发送一个请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    [mgr POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        //NSData *fileData = UIImagePNGRepresentation(image);
        NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
        [formData appendPartWithFileData:fileData name:@"fileData" fileName:@"icon" mimeType:@"image/png"];
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSLog(@"上传成功-uploge%@",responseObject);
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
//            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showSuccess:@"个人信息设置成功"];
            
            // 成功后发送一个通知
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            dict[@"newName"] = self.nickName.text;
//            if ([self.nickName.text isEqualToString:@""]) {
//                dict[@"newName"] = self.number.text;
//            }
            
            
            
            
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"successSETInfo" object:self userInfo:dict];

            // 最后来根据这个ID下载最新的信息 以免在其他客户端改变了东西没有及时改过来  - 只下载 不设置
            [self uploadNewInfo:userID];

            
            [self.navigationController popViewControllerAnimated:YES];

        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1000"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        NSLog(@"上传失败-upload:%@",error);
        NSLog(@"登录失败---%@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"设置失败"];
        
    }];
}



#pragma mark - 上传以后就下载最新保存；

-(void)uploadNewInfo:(NSString *)mID{
    
    
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
        
        // 拼接名片
        NSString * str3 = dict[@"mCardUrl"];
        if (![dict[@"mCardUrl"] isEqualToString:@""]) {
            str3 = [NSString stringWithFormat:@"%@%@",SERVER_URL,str3];
        }
        dict[@"mCardUrl"] = str3;
        
        
        NSLog(@"请求成功--下载跟新个人信息--%@",dict);
        
        
        // 更新了最新的 我们要重新保存一遍
        [WDInfoTool creatAccountPlist:dict];
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");

        
    }];
    
    
}


@end
