//
//  newHomeBtn.m
//  touwhoIphone
//
//  Created by 投壶 on 16/1/8.
//  Copyright © 2016年 投壶. All rights reserved.
//

#import "newHomeBtn.h"
#import "UIView+Extension.h"


@interface newHomeBtn ()

@property (assign ,nonatomic) BOOL select;

@end

@implementation newHomeBtn

/*
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
     Drawing code
}
*/

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSLog(@"11111---初始化方法");
        
        self.select = NO;
    
    }
    return  self;
}

-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    
    if (self.select ==YES) return;

    NSLog(@"11111--高亮状态的");
    
    if (self.select == NO) {
        self.select = YES;
        CGRect newFrame = [self convertRect:self.bounds fromView:self.superview];
      //  NSLog(@"newFrame - frame-x-%f--frame-y-%f",newFrame.origin.x,newFrame.origin.y);
        
        if (newFrame.origin.x < 0) {
            newFrame.origin.x = -newFrame.origin.x;
        }
        if (newFrame.origin.y < 0) {
            newFrame.origin.y = -newFrame.origin.y;
        }
        
        UIImageView * imageView = [[UIImageView alloc] init];
        [imageView setFrame:CGRectMake(newFrame.origin.x, newFrame.origin.y, self.width, self.height)];
        [imageView setImage:[UIImage imageNamed:@"newHomeGQTent"]];
        [self.superview addSubview:imageView];
        [self setAlpha:0.0f];
        [imageView setAlpha:0.4f];
        [UIView animateWithDuration:0.3f animations:^{
            imageView.layer.transform = CATransform3DMakeScale(2, 2, 2);
            //  [self setAlpha:0.0f];
            [imageView setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
              self.select = NO;
            [self setAlpha:1.0f];
            [imageView removeFromSuperview];
        }];

    
    
    
    }
    
}



@end
