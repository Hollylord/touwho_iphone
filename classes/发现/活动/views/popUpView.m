//
//  popUpView.m
//  ad
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "popUpView.h"
#import "UIView+Extension.h"
#define kArrorHeight    10


@interface popUpView ()
@property (weak , nonatomic)  UILabel *time;
@property (weak , nonatomic)  UITextView *place;
@property (weak , nonatomic)  UILabel *activityName;
@end

@implementation popUpView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *background= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"biaoqian"]];
//        if ([[UIScreen mainScreen] bounds].size.width > 375) {
//            
//            CGRect frame = background.frame;
//            frame =CGRectMake(frame.origin.x, frame.origin.y, 300, 170);
//            background.frame = frame;
//        }
        
        
        [self addSubview:background];
        
        UILabel *activityName = [[UILabel alloc] init];
        activityName.frame = CGRectMake(30, 10, 250, 20);
        activityName.textAlignment = NSTextAlignmentCenter;
//        activityName.backgroundColor = [UIColor redColor];
//        activityName.text = @"活动名称";
        activityName.text = self.mTitle;

        [self addSubview:activityName];
        self.activityName = activityName;
        
        UILabel *time = [[UILabel alloc] init];
//        time.backgroundColor = [UIColor orangeColor];
        time.numberOfLines = 0;
        time.textAlignment = NSTextAlignmentCenter;
        time.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
//        time.text = @"时间：14：00-16：00PM";
        time.text = [NSString stringWithFormat:@"时间:%@",self.mTime];
        
        self.time = time;

        //通过字体动态计算高度
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:time.font forKey:NSFontAttributeName];
        CGSize timeSize = [time.text boundingRectWithSize:CGSizeMake(150, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        time.frame = CGRectMake(30, 70, 250, timeSize.height);
        [self addSubview:time];
        
        UITextView *place = [[UITextView alloc] init];
//        place.backgroundColor = [UIColor blueColor];
        [place setFont:[UIFont systemFontOfSize:14.0f]];
        place.text = self.mAddress;
        [place setBackgroundColor:[UIColor clearColor]];
        place.textAlignment = NSTextAlignmentCenter;
        //通过字体计算label高度
//        NSDictionary *attribute = [NSDictionary dictionaryWithObject:place.font forKey:NSFontAttributeName];
//        CGSize placeSize = [place.text boundingRectWithSize:CGSizeMake(250, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        place.frame = CGRectMake(30, 100, 250, self.height - 100);
        [self addSubview:place];
    
        
        self.place = place;
    }
    return self;
}



-(void)setMTitle:(NSString *)mTitle{
    _activityName.text = mTitle;
}

-(void)setMTime:(NSString *)mTime{
    _time.text = mTime;
}

-(void)setMAddress:(NSString *)mAddress{
   _place.text = mAddress;
 //   _place.text = @"15-11-23 14:24:25.026 touwhoIphone[1455:369492] latitude : 22.534641,longitude: 113.9";

}


//#pragma mark - draw rect
//
//- (void)drawRect:(CGRect)rect
//{
//    
//    [self drawInContext:UIGraphicsGetCurrentContext()];
//    
//    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowOpacity = 1.0;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    
//}
//
//- (void)drawInContext:(CGContextRef)context
//{
//    
//    CGContextSetLineWidth(context, 2.0);
//    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
//    
//    [self getDrawPath:context];
//    CGContextFillPath(context);
//    
//}
//
//- (void)getDrawPath:(CGContextRef)context
//{
//    CGRect rrect = self.bounds;
//    CGFloat radius = 6.0;
//    CGFloat minx = CGRectGetMinX(rrect),
//    midx = CGRectGetMidX(rrect),
//    maxx = CGRectGetMaxX(rrect);
//    CGFloat miny = CGRectGetMinY(rrect),
//    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
//    
//    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
//    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
//    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
//    
//    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
//    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
//    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
//    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
//    CGContextClosePath(context);
//}




@end
