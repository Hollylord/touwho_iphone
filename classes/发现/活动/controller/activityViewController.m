//
//  activityViewController.m
//  ad
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "activityViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "customAnnotationView.h"
#import "popUpView.h"
#import <AMapSearchKit/AMapSearchKit.h>// 搜索功能；

@interface activityViewController () <MAMapViewDelegate,AMapSearchDelegate>
{
//    MAMapView *_map;
    MAMapView *mapView;
    MAPointAnnotation *_annotation;
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    
   // CLLocationManager * locationManager;

}
@end

@implementation activityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [MAMapServices sharedServices].apiKey = @"2096197a1797001b9809d5bc816c7fc3";
    
    mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    mapView.delegate = self;
    
    [self.view addSubview:mapView];
    
    
     // 显示定位原点
    mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位  开启定位
    
    
    
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
    geo.address = self.mAddress;
    
    //发起正向地理编码
    [_search AMapGeocodeSearch: geo];
    
    
    
//    
//    locationManager =[[CLLocationManager alloc] init];
//    
//    // fix ios8 location issue
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
//#ifdef __IPHONE_8_0
//        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
//        {
//            [locationManager performSelector:@selector(requestAlwaysAuthorization)];//用这个方法，plist中需要NSLocationAlwaysUsageDescription
//        }
//        
//        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
//        {
//            [locationManager performSelector:@selector(requestWhenInUseAuthorization)];//用这个方法，plist里要加字段NSLocationWhenInUseUsageDescription
//        }
//#endif
    
    
    
    
//    [MAMapServices sharedServices].apiKey = @"2096197a1797001b9809d5bc816c7fc3";
//    MAMapView *mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    _map = mapView;
//    _map.delegate = self;
// 
//    MACoordinateRegion customRegion = MACoordinateRegionMake(_map.centerCoordinate, MACoordinateSpanMake(0.1, 0.1));
//    [_map setRegion:customRegion animated:YES];
//    _map.showsUserLocation = YES;
//    _map.userTrackingMode = 1;
//    [_map setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
//    [self.view addSubview:mapView];
//    
//    //搜索设置
//    _searchAPI = [[AMapSearchAPI alloc] init];
//    _searchAPI = [AMapSearchAPI ]
//    _searchAPI.delegate = self;
//    
//    AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc] init];
//    //request.city = @[@"深圳"];
//    request.address = @"五和";
//    [_searchAPI AMapGeocodeSearch:request];
    
    
      //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项

    
    
    
}
//- (void)viewWillDisappear:(BOOL)animated{
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
//}


#pragma mark - searchAPI 回调
//- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
//    AMapGeocode *geoCode = response.geocodes[0];
//    
//    //配置annotation
//    _annotation = [[MAPointAnnotation alloc] init];
//    _annotation.coordinate = CLLocationCoordinate2DMake(geoCode.location.latitude, geoCode.location.longitude);
//    _annotation.title = @"工作地点";
//    _annotation.subtitle = @"卫东龙商务大厦";
//    [_map addAnnotation:_annotation];
//    
//}
//

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
    
    _annotation.title = self.mTitle;
    _annotation.subtitle = self.mAddress;
        [mapView addAnnotation:_annotation];

       // [_map addAnnotation:_annotation];
    
    
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
        [mapView setRegion:region animated:YES];
   // });


    
}

//- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
//{
////    
////    NSLog(@"onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response");
////    
////    if(response.geocodes.count == 0)
////    {
////        return;
////    }
////    
////    //通过AMapGeocodeSearchResponse对象处理搜索结果
////    NSString *strCount = [NSString stringWithFormat:@"count: %ld", (long)response.count];
////    NSString *strGeocodes = @"";
////    for (AMapTip *p in response.geocodes) {
////        strGeocodes = [NSString stringWithFormat:@"%@\ngeocode: %@", strGeocodes, p.description];
////    }
////    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strGeocodes];
////    NSLog(@"Geocode: %@", result);
////    
////    AMapGeocode *geoCode = response.geocodes[0];
////    
////        //配置annotation
////        _annotation = [[MAPointAnnotation alloc] init];
////        _annotation.coordinate = CLLocationCoordinate2DMake(geoCode.location.latitude, geoCode.location.longitude);
////        _annotation.title = @"工作地点";
////        _annotation.subtitle = @"卫东龙商务大厦";
////        [_map addAnnotation:_annotation];
////
//    
//}



//
//
//
#pragma mark - annotationView
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *reusedID = @"annotation";
       customAnnotationView *annotationView = (customAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedID];
        if (annotationView == nil) {
            annotationView = [[customAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedID];
            annotationView.mTitle = self.mTitle;
            annotationView.mTime = self.mTime;
            annotationView.mAddress = self.mAddress;
        }
        annotationView.image = [UIImage imageNamed:@"touhu"];
//        [annotationView setSelected:YES animated:YES];
        
        return annotationView;
    }
    return nil;
    
}


- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if (view.selected == YES) {
        [view setSelected:NO animated:YES];
    }
    else {
        [view setSelected:YES animated:YES];
    }
}


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



- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    customAnnotationView *annotation = views[0];
    annotation.selected = YES;
}


//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MAPointAnnotation class]])
//    {
//        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
//        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
//        }
//        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorPurple;
//        return annotationView;
//    }
//    return nil;
//}



//-(void)viewDidDisappear:(BOOL)animated{
//    // [self dismissViewControllerAnimated:YES completion:nil];
//    [self.view removeFromSuperview];
//}
//
@end
