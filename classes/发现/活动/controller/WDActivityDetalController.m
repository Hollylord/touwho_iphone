//
//  WDActivityDetalController.m
//  ZBT
//
//  Created by 投壶 on 15/10/26.
//  Copyright © 2015年 touwho. All rights reserved.
//

#import "WDActivityDetalController.h"
#import "WDActivityDetailModel.h"
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>
#import  <MJExtension.h> // 字典转模型
#import <SDWebImage/UIImageView+WebCache.h>

#import "UMSocial.h"

#import "WDInfoTool.h"  // 获取userid
#import "TalkingData.h" // talkdata
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "customAnnotationView.h"
//#import "popUpView.h"
#import <AMapSearchKit/AMapSearchKit.h>// 搜索功能；



@interface WDActivityDetalController ()<UMSocialUIDelegate,MAMapViewDelegate,AMapSearchDelegate>

@property (assign,nonatomic) BOOL iSdianzan;
@property (weak, nonatomic) IBOutlet UILabel *mTitle; //活动标题
@property (weak, nonatomic) IBOutlet UILabel *mTime;  // 活动时间
@property (weak, nonatomic) IBOutlet UILabel *mAddress;  // 活动地址

@property (weak, nonatomic) IBOutlet MAMapView *mapView;


//保存当前页面的详情
@property (strong ,nonatomic) WDActivityDetailModel * detailModel;

@property (weak, nonatomic) IBOutlet UIButton *baoming;

- (IBAction)baomingClick:(id)sender;

@end

@implementation WDActivityDetalController
{
    
    MAPointAnnotation *_annotation;
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    
    // CLLocationManager * locationManager;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.iSdianzan = NO;

    // 如果是已经进行或者结束的隐藏报名按钮
    if (![self.model.mStatus isEqualToString:@"0"]) {
        NSLog(@" if (![self.model.mStatus isEqualToStri");
        NSLog(@"------%@",self.model.mStatus);
        self.baoming.hidden = YES;
    }

    
    // 设置活动页面上面的信息；
    [self settingInitContent];
    
    [self settingMap];
    
    // 请求活动详情；
    [self requestActivityContent];
    
    
    
    
    
}


-(void)settingInitContent{
    WDActivityListModel * model = self.model;
    self.mTitle.text = model.mTitle;
    self.mTime.text = model.mTime;
    self.mAddress.text = model.mAddress;
}


-(void)requestActivityContent{
    // 1.创建一个请求操作管理者
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请
    
//    // 首先要获得最上面的窗口
//    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
//    
//    //设置进度条；
//    [MBProgressHUD showMessage:@"正在加载" toView:window];
//    
    //加载网络数据
    // 2.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"method"] = @"getActivityDetail";
    params[@"activity_id"] = self.model.mID;

    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
  //  NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
      //  [MBProgressHUD hideHUDForView:window animated:YES];
        NSDictionary * dict = [[responseObject objectForKey:@"value"] firstObject];
        
        WDActivityDetailModel * detailModel = [WDActivityDetailModel objectWithKeyValues:dict];
        self.detailModel = detailModel;
        
        if([self.model.mStatus isEqualToString:@"0"]&&[detailModel.mIsRegActivity isEqualToString:@"1"]){
            self.baoming.hidden = NO;
            [self.baoming setTitle:@"已报名" forState:UIControlStateNormal];
            self.baoming.userInteractionEnabled = NO;
        }
        
        if([self.model.mStatus isEqualToString:@"0"]&&[detailModel.mIsRegActivity isEqualToString:@"0"]){
            self.baoming.hidden = NO;
            [self.baoming setTitle:@"报名活动" forState:UIControlStateNormal];
            self.baoming.userInteractionEnabled = YES;
        }
        
        
        
//        //成功
//        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
//          //  NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
//         // [MBProgressHUD showSuccess:@""];
//            
//        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
    //    [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)baomingClick:(id)sender {
    
    NSString * userID = [WDInfoTool getLastAccountPlistUserID];
    if ([userID isEqualToString:@""] || userID ==nil) {
        [MBProgressHUD showError:@"请先登录"];
        return;
    }

    
    
    // 1. 创建一个请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes  = [NSSet setWithObject:@"text/html"];
    
    // 首先要获得最上面的窗口
    UIWindow * window = [[UIApplication sharedApplication].windows lastObject];
    
    //设置进度条；
    [MBProgressHUD showMessage:@"正在加载" toView:window];

    
    //2.字典
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"method"] = @"activityReg";
    params[@"user_id"] = userID;
    params[@"activity_id"] = self.model.mID;
    
    
    // 3.发送一个GET请求
    NSString *url = @"http://120.25.215.53:8099/api.aspx";
    //  NSString * SERVER_URL = @"http://120.25.215.53:8099/";
    
    
    [mgr GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        // 请求成功的时候调用这个block
        NSLog(@"请求成功--%@", responseObject);
        //成功以后我就进度条
        [MBProgressHUD hideHUDForView:window animated:YES];

        
        
        //成功
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"0"]) {
              NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
             [MBProgressHUD showSuccess:str];
            
    
            
        }
        //失败
        
        if ([[[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resCode"] isEqualToString:@"-1"]) {
            NSString * str = [[[responseObject objectForKey:@"value"] firstObject] objectForKey:@"resValue"];
            [MBProgressHUD showError:str];
        }
        

        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
        // 请求失败的时候调用调用这个block
        NSLog(@"请求失败");
        
        [MBProgressHUD hideHUDForView:window animated:YES];
        [MBProgressHUD showError:@"网络连接错误"];
        
        

        
        
    }];
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * str = [NSString stringWithFormat:@"活动-%@",self.model.mTitle];
    [TalkingData trackPageBegin:str];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * str = [NSString stringWithFormat:@"活动-%@",self.model.mTitle];
    [TalkingData trackPageEnd:str];
}


#pragma mark - 地图
- (void)settingMap{
    [MAMapServices sharedServices].apiKey = @"2096197a1797001b9809d5bc816c7fc3";
    _mapView.delegate = self;
    _mapView.showsScale = NO;
    _mapView.showsCompass = NO;
    // 显示定位原点
    _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位  开启定位
    
    
    
    // 制定位置的图
    _annotation = [[MAPointAnnotation alloc] init];
    //    pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
    //    pointAnnotation.title = @"方恒国际";
    //    pointAnnotation.subtitle = @"阜通东大街6号";
    
    //    [mapView addAnnotation:_annotation];
    
    
    //设置搜索API
    [AMapSearchServices sharedServices].apiKey = @"2096197a1797001b9809d5bc816c7fc3";
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    //geo.city = @"深圳";
    // 设置地点
    geo.address = self.mAddress.text;
    
    //发起正向地理编码
    [_search AMapGeocodeSearch: geo];

}
//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0)
    {
        return;
    }
    
    //通过AMapGeocodeSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld", (long)response.count];
    NSString *strGeocodes = @"";
    for (AMapTip *p in response.geocodes) {
        strGeocodes = [NSString stringWithFormat:@"%@\ngeocode: %@", strGeocodes, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strGeocodes];
    NSLog(@"Geocode: %@", result);
    
    
    AMapGeocode *geoCode = response.geocodes[0];
    
    //配置annotation
    //_annotation = [[MAPointAnnotation alloc] init];
    _annotation.coordinate = CLLocationCoordinate2DMake(geoCode.location.latitude, geoCode.location.longitude);
    
    
    // 设置标题 和地点
    
    _annotation.title = self.mTitle.text;
    _annotation.subtitle = self.mAddress.text;
    [_mapView addAnnotation:_annotation];
    
    
    
    // 定位到这里
    // 设置地图显示的区域
    // 获取用户的位置
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(geoCode.location.latitude, geoCode.location.longitude);;
    // 指定经纬度的跨度
    MACoordinateSpan span = MACoordinateSpanMake(0.2252,0.15853);
    //0.021708 0.013733  0.009252 0.005853
    // 将用户当前的位置作为显示区域的中心点, 并且指定需要显示的跨度范围
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    
    
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    [_mapView setRegion:region animated:YES];
    // });
    
    
    
}

#pragma mark - annotationView
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *reusedID = @"annotation";
        customAnnotationView *annotationView = (customAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedID];
        if (annotationView == nil) {
            annotationView = [[customAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedID];
            annotationView.mTitle = self.mTitle.text;
            annotationView.mTime = self.mTime.text;
            annotationView.mAddress = self.mAddress.text;
        }
        annotationView.image = [UIImage imageNamed:@"touhu"];
        
        
        return annotationView;
    }
    return nil;
    
}


//- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
//    if (view.selected == YES) {
//        [view setSelected:NO animated:YES];
//    }
//    else {
//        [view setSelected:YES animated:YES];
//    }
//}


//当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标，示例代码如下：
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        
    }
    
    
}



//- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
//    customAnnotationView *annotation = views[0];
//    annotation.selected = YES;
//}

@end
