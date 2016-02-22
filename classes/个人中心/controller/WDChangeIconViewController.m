//
//  WDChangeIconViewController.m
//  ZBT
//
//  Created by 投壶 on 15/9/25.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDChangeIconViewController.h"
#import <MobileCoreServices/MobileCoreServices.h> // 摄像头
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking.h>

@interface WDChangeIconViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *icon;

- (IBAction)upLoad:(UIButton *)sender;
- (IBAction)sureBtn:(id)sender;


- (IBAction)btn11:(UIButton *)sender;
- (IBAction)btn12:(UIButton *)sender;
- (IBAction)btn13:(UIButton *)sender;
- (IBAction)btn14:(UIButton *)sender;
- (IBAction)btn15:(UIButton *)sender;
- (IBAction)btn16:(UIButton *)sender;

- (IBAction)btn21:(UIButton *)sender;
- (IBAction)btn22:(UIButton *)sender;
- (IBAction)btn23:(UIButton *)sender;
- (IBAction)btn24:(UIButton *)sender;
- (IBAction)btn25:(UIButton *)sender;
- (IBAction)btn26:(UIButton *)sender;

@end

@implementation WDChangeIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.cornerRadius = 6.0;
    self.icon.layer.borderWidth = 1.0;
    self.icon.layer.borderColor = [[UIColor grayColor] CGColor];
    
    [self.icon setImage:self.image];
    
  //  [self.icon sd_setImageWithURL:[NSURL URLWithString:self.iconUrl] placeholderImage:[UIImage imageNamed:@"touxiang"]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 上拉框
- (IBAction)upLoad:(UIButton *)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
    [sheet showInView:self.view.window];
}

- (IBAction)sureBtn:(id)sender {
    
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - UIActionSheet-上拉框毁掉
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"dfdsjfkjdsfjksdhk---%ld",(long)buttonIndex);
    
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
    [self.icon setImage:image];
   // 上传
    [self upload:image];
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

#pragma mark - 上传照片
- (void)upload:(UIImage *)image
{
    // 1.创建一个管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    //设置管理者
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
   [mgr.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    // 2.封装参数(这个字典只能放非文件参数)
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"alterAvatar";
    params[@"user_id"] = self.mID;

    // 2.发送一个请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    NSString * SERVER_URL = @"http://120.25.215.53:8099";
    [mgr POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        

    //NSData *fileData = UIImagePNGRepresentation(image);
    NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    [formData appendPartWithFileData:fileData name:@"fileData" fileName:@"icon" mimeType:@"image/png"];
    

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"上传成功");
        NSLog(@"shangchuanshibsuccessr -%@",responseObject);
        
        NSDictionary * dictionary = [[responseObject objectForKey:@"value"] firstObject];
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        NSString * str = dictionary[@"resValue"];
        str = [NSString stringWithFormat:@"%@%@",SERVER_URL,str];
        dict[@"mAvatar"] =str;
        
        // 登录成功后 发送登录成功的通知
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"successChangeAvatar" object:self userInfo:dict];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"上传失败");
       // NSLog(@"shangchuanshibaioperation -%@",operation);
        NSLog(@"shangchuanshibaerror -%@",error);
    }];
}




- (IBAction)btn11:(UIButton *)sender {
     [self.icon setImage:[UIImage imageNamed:@"myicon01"]];
    // 上传
    [self upload:self.icon.image];
}

- (IBAction)btn12:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon02"]];
    [self upload:self.icon.image];
}

- (IBAction)btn13:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon03"]];
    [self upload:self.icon.image];
}

- (IBAction)btn14:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon04"]];
    [self upload:self.icon.image];
}

- (IBAction)btn15:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon05"]];
    [self upload:self.icon.image];

}

- (IBAction)btn16:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon06"]];
    [self upload:self.icon.image];
}

- (IBAction)btn21:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon07"]];
}

- (IBAction)btn22:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon08"]];
    [self upload:self.icon.image];
}

- (IBAction)btn23:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon09"]];
    [self upload:self.icon.image];
}

- (IBAction)btn24:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon10"]];
    [self upload:self.icon.image];

}

- (IBAction)btn25:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon11"]];
    [self upload:self.icon.image];

}

- (IBAction)btn26:(UIButton *)sender {
    [self.icon setImage:[UIImage imageNamed:@"myicon12"]];
    [self upload:self.icon.image];

}





@end
