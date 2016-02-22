//
//  WDPickerView.m
//  ZBT
//
//  Created by 投壶 on 15/9/29.
//  Copyright (c) 2015年 touwho. All rights reserved.
//

#import "WDPickerView.h"

@interface WDPickerView()
{
    NSArray *firstList, *secondList, *thirdList, *aRRyiliaojiankang,*aRRqita;   // 省份，城市，区
}

@property(copy,nonatomic) NSString * currentfirstListitem;
@property(copy,nonatomic) NSString * currentsecondListListitem;


@end


@implementation WDPickerView


-(WDAreaModel *)locate
{
    if (_locate == nil) {
        _locate = [[WDAreaModel alloc] init];
    }
    
    return _locate;
}

/**
 *  这个是最先调用的 1
 *
 *   */
- (id)initWithStyle:(WDPickerStyle)pickerStyle delegate:(id<WDPickerViewDelegate>)delegate{
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"WDPickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        
        // 代理设置
       self.delegate = delegate;    // 这里把外面的复制过来。。
       self.pickerStyle = pickerStyle;   // 这里把外面的复制过来。。
       self.WDpickerview.dataSource = self;
       self.WDpickerview.delegate = self;
        
        //加载数据
        if (self.pickerStyle == WDPickerStyle3shenghuidiquchengshi) {
            // 第一个列数组 ， 第二列数组
            firstList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
            secondList = [[firstList objectAtIndex:0] objectForKey:@"cities"];
            
             // 设置第一个列数组 ， 第二列数组
            self.locate.state = [[firstList objectAtIndex:0] objectForKey:@"state"];  // 省会赋值 (字符串)
            self.locate.city = [[secondList objectAtIndex:0] objectForKey:@"city"];   // 城市赋值 (字符串)
            
            
            //第三列数组
            thirdList = [[secondList objectAtIndex:0] objectForKey:@"areas"];
            if (thirdList.count > 0) {
                self.locate.district = [thirdList objectAtIndex:0];  //  设置城市 (字符串)
            } else{
                self.locate.district = @"";
            }
            
        }
        
        
        if(self.pickerStyle == WDPickerStyle2){
            firstList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city.plist" ofType:nil]];
            secondList = [[firstList objectAtIndex:0] objectForKey:@"cities"];
            self.locate.state = [[firstList objectAtIndex:0] objectForKey:@"state"];
            self.locate.city = [secondList objectAtIndex:0];
        }
        
        
        if (self.pickerStyle == WDPickerStyle1projectPhase) {
            firstList =[[NSArray alloc] initWithObjects:@"种子期",@"A轮",@"B轮",@"C轮",@"Pre-IPO",@"其他", nil];
            self.locate.projectPhase = [firstList objectAtIndex:0];
        }
        
        if (self.pickerStyle == WDPickerStyle1suochuhangye) {
            firstList =[[NSArray alloc] initWithObjects:@"自由职业",@"金融业",@"医疗健康",@"服务业",@"制造业",@"教育∕科研",@"其他", nil];
            self.locate.suochuhangye = [firstList objectAtIndex:0];
        }
        
        
        if (self.pickerStyle == WDPickerStyle1age) {
            firstList =[[NSArray alloc] initWithObjects:@"50后",@"60后",@"70后",@"80后",@"90后", nil];
            self.locate.age = [firstList objectAtIndex:0];
        }
        
        if (self.pickerStyle == WDPickerStyle1ganxingquehangye) {
            firstList =[[NSArray alloc] initWithObjects:@"医疗健康",@"TMT",@"新能源",@"环保",@"服务业",@"制造业",@"其他", nil];
            self.locate.ganxingquhangye = [firstList objectAtIndex:0];
        }

        if (self.pickerStyle == WDPickerStyle1fengxianpianhao) {
            firstList =[[NSArray alloc] initWithObjects:@"保守型",@"平衡型",@"增长型",@"进取型", nil];
            self.locate.fengxianpianhao = [firstList objectAtIndex:0];
        }

        
        // 入驻单位 {初始化数据}
        if (self.pickerStyle == WDPickerStyle3ruzhudanwei) {
            
            firstList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"organization.plist" ofType:nil]];
          secondList = [[firstList objectAtIndex:0] objectForKey:@"subClass"];
          thirdList = [[secondList objectAtIndex:0] objectForKey:@"subClass"];
        
//
//            self.locate.industry1 = [[firstList objectAtIndex:0] objectForKey:@"name"];
//            self.locate.industry2 = @"";
//            self.locate.industry3 = @"";



        }
        

        
        
    }
    
    return self;
    
}



#pragma mark - PickerView lifecycle
/**
 *  这个是第二调用的 2  （调用了两次）
 * */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if (self.pickerStyle == WDPickerStyle3shenghuidiquchengshi) {
        return 3;
    }
    if (self.pickerStyle == WDPickerStyle2) {
        return 2;
    }
    
    if (self.pickerStyle == WDPickerStyle1projectPhase) {
        return 1;
    }
    
    if (self.pickerStyle == WDPickerStyle1age) {
        return 1;
    }
    if (self.pickerStyle == WDPickerStyle1suochuhangye) {
        return 1;
    }

    if (self.pickerStyle == WDPickerStyle1ganxingquehangye) {
        return 1;
    }

    if (self.pickerStyle == WDPickerStyle1fengxianpianhao) {
        return 1;
    }
    
    if (self.pickerStyle == WDPickerStyle3ruzhudanwei) {
        return 3;
    }
        return 3;
}

/**
 *   这个是第三个调用的 调用了很多次
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    if (self.pickerStyle == WDPickerStyle3shenghuidiquchengshi) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            case 1:
                return [secondList count];
                break;
            case 2:
                return [thirdList count];
                break;
            default:
                return 0;
                break;
          }
    }
    
    
    if (self.pickerStyle == WDPickerStyle1projectPhase) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            default:
                return 0;
                break;
        }

        
    }
    
    
    if (self.pickerStyle == WDPickerStyle2) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            case 1:
                return [secondList count];
                break;
            default:
                return 0;
                break;
        }

    }
    
    if (self.pickerStyle == WDPickerStyle1age) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            default:
                return 0;
                break;
        }
        
        
    }

    
    if (self.pickerStyle == WDPickerStyle1ganxingquehangye) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            default:
                return 0;
                break;
        }
        
        
    }

    
    if (self.pickerStyle == WDPickerStyle1suochuhangye) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            default:
                return 0;
                break;
        }
        
        
    }

    
    if (self.pickerStyle == WDPickerStyle1fengxianpianhao) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            default:
                return 0;
                break;
        }
        
        
    }
    
    if (self.pickerStyle == WDPickerStyle3ruzhudanwei) {
        switch (component) {
            case 0:
                return [firstList count];
                break;
            case 1:
                return [secondList count];
                break;
            case 2:
                return [thirdList count];
                break;
            default:
                return 0;
                break;
        }
    }


    
    return 0;
}

/**
 *  最后一个调用的 （每次都会）
 * */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
    if (self.pickerStyle == WDPickerStyle3shenghuidiquchengshi) {
        switch (component) {
            case 0:
                return [[firstList objectAtIndex:row] objectForKey:@"state"];   // 数组里有字典;
                break;
            case 1:
                return [[secondList objectAtIndex:row] objectForKey:@"city"];   // 数组里有字典;
                break;
            case 2:
                if ([thirdList count] > 0) {
                    return [thirdList objectAtIndex:row];
                    break;
                }
            default:
                return  @"";
                break;
        }
    }
    
    if (self.pickerStyle == WDPickerStyle2)
    {
        switch (component) {
            case 0:
                return [[firstList objectAtIndex:row] objectForKey:@"state"];   // 数组里有字典;
                break;
            case 1:
                return [secondList objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }
    
    
    if (self.pickerStyle == WDPickerStyle1projectPhase)
    {
        switch (component) {
            case 0:
                return [firstList objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }

    
    
    if (self.pickerStyle == WDPickerStyle1age)
    {
        switch (component) {
            case 0:
                return [firstList objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }

    if (self.pickerStyle == WDPickerStyle1suochuhangye)
    {
        switch (component) {
            case 0:
                return [firstList objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }

    if (self.pickerStyle == WDPickerStyle1ganxingquehangye)
    {
        switch (component) {
            case 0:
                return [firstList objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }

    if (self.pickerStyle == WDPickerStyle1fengxianpianhao)
    {
        switch (component) {
            case 0:
                return [firstList objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }

    
    
    if (self.pickerStyle == WDPickerStyle3ruzhudanwei){
        switch (component) {
            case 0:
                return [[firstList objectAtIndex:row] objectForKey:@"name"];   // 数组里有字典;
                break;
            case 1:
                if ([secondList count] > 0) {
                    return [[secondList objectAtIndex:row] objectForKey:@"name"];
                    break;
                }
            case 2:
                if ([thirdList count] > 0) {
                    return [thirdList objectAtIndex:row];
                    break;
                }
            default:
                return  @"";
                break;
        }
    }


    
    
    return @"";
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    

    if (self.pickerStyle == WDPickerStyle3shenghuidiquchengshi) {
        switch (component) {
            case 0:
                secondList = [[firstList objectAtIndex:row] objectForKey:@"cities"];// 拿出对应的省会列表
                [self.WDpickerview selectRow:0 inComponent:1 animated:YES];
                [self.WDpickerview reloadComponent:1];   // 刷新某一列列表
                
                
                thirdList = [[secondList objectAtIndex:0] objectForKey:@"areas"];   //拿出城市
                [self.WDpickerview selectRow:0 inComponent:2 animated:YES]; //第3列滑动到第0个
                [self.WDpickerview reloadComponent:2];  // 刷新某一列列表
                
                self.locate.state = [[firstList objectAtIndex:row] objectForKey:@"state"];// 省会赋值(字符串)
                self.locate.city = [[secondList objectAtIndex:0] objectForKey:@"city"];// 城市赋值(字符串)
                if ([thirdList count] > 0) {
                    self.locate.district = [thirdList objectAtIndex:0];
                } else{
                    self.locate.district = @"";
                }
                break;
            case 1:
                thirdList = [[secondList objectAtIndex:row] objectForKey:@"areas"];
                [self.WDpickerview selectRow:0 inComponent:2 animated:YES];
                [self.WDpickerview reloadComponent:2];
                
                self.locate.city = [[secondList objectAtIndex:row] objectForKey:@"city"];
                if ([thirdList count] > 0) {
                    self.locate.district = [thirdList objectAtIndex:0];
                } else{
                    self.locate.district = @"";
                }
                break;
            case 2:
                if ([thirdList count] > 0) {
                    self.locate.district = [thirdList objectAtIndex:row];
                } else{
                    self.locate.district = @"";
                }
                break;
            default:
                break;
        }
    }
    if (self.pickerStyle == WDPickerStyle2)
    {
        switch (component) {
            case 0:
                secondList = [[firstList objectAtIndex:row] objectForKey:@"cities"];
                [self.WDpickerview selectRow:0 inComponent:1 animated:YES];
                [self.WDpickerview reloadComponent:1];
                
                self.locate.state = [[firstList objectAtIndex:row] objectForKey:@"state"];
                self.locate.city = [secondList objectAtIndex:0];
                break;
            case 1:
                self.locate.city = [secondList objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    
    if (self.pickerStyle == WDPickerStyle1projectPhase)
    {
        switch (component) {
            case 0:
                self.locate.projectPhase = [firstList objectAtIndex:row]; //只设置字符 在这里设置
//                [self.WDpickerview selectRow:0 inComponent:0 animated:YES];
//                [self.WDpickerview reloadComponent:0];
                break;
            default:
                self.locate.projectPhase = @"";
                break;
        }
    }
    
    
    if (self.pickerStyle == WDPickerStyle1fengxianpianhao)
    {
        switch (component) {
            case 0:
                self.locate.fengxianpianhao = [firstList objectAtIndex:row]; //只设置字符 在这里设置
                //                [self.WDpickerview selectRow:0 inComponent:0 animated:YES];
                //                [self.WDpickerview reloadComponent:0];
                break;
            default:
                self.locate.fengxianpianhao = @"";
                break;
        }
    }

    if (self.pickerStyle == WDPickerStyle1age)
    {
        switch (component) {
            case 0:
                self.locate.age = [firstList objectAtIndex:row]; //只设置字符 在这里设置
                //                [self.WDpickerview selectRow:0 inComponent:0 animated:YES];
                //                [self.WDpickerview reloadComponent:0];
                break;
            default:
                self.locate.age = @"";
                break;
        }
    }

    if (self.pickerStyle == WDPickerStyle1suochuhangye)
    {
        switch (component) {
            case 0:
                self.locate.suochuhangye = [firstList objectAtIndex:row]; //只设置字符 在这里设置
                //                [self.WDpickerview selectRow:0 inComponent:0 animated:YES];
                //                [self.WDpickerview reloadComponent:0];
                break;
            default:
                self.locate.suochuhangye = @"";
                break;
        }
    }

    if (self.pickerStyle == WDPickerStyle1ganxingquehangye)
    {
        switch (component) {
            case 0:
                self.locate.ganxingquhangye = [firstList objectAtIndex:row]; //只设置字符 在这里设置
                //                [self.WDpickerview selectRow:0 inComponent:0 animated:YES];
                //                [self.WDpickerview reloadComponent:0];
                break;
            default:
                self.locate.ganxingquhangye = @"";
                break;
        }
    }


    
    if (self.pickerStyle == WDPickerStyle3ruzhudanwei){
        
        switch (component) {
            case 0:
                secondList = [[firstList objectAtIndex:row] objectForKey:@"subClass"];// 拿出对应的省会列表
                [self.WDpickerview selectRow:0 inComponent:1 animated:YES];
                [self.WDpickerview reloadComponent:1];   // 刷新某一列列表
                
                if ([secondList count]>0) {
                    thirdList = [[secondList objectAtIndex:0] objectForKey:@"subClass"];   //拿出城市

                }else{
                    thirdList = nil;
                }
                
                [self.WDpickerview selectRow:0 inComponent:2 animated:YES]; //第3列滑动到第0个
                [self.WDpickerview reloadComponent:2];  // 刷新某一列列表

                
                self.locate.industry1 = [[firstList objectAtIndex:row] objectForKey:@"name"];
                
                if ([secondList count] > 0) {
                    self.locate.industry2 = [[secondList objectAtIndex:0] objectForKey:@"name"];                }else{
                        self.locate.industry2 = @"";
                    }
                

                if ([thirdList count] > 0) {
                    self.locate.industry3 = [thirdList objectAtIndex:0];
                } else{
                    self.locate.industry3 = @"";
                }
                break;
            case 1:
                thirdList = [[secondList objectAtIndex:row] objectForKey:@"subClass"];
                [self.WDpickerview selectRow:0 inComponent:2 animated:YES];
                [self.WDpickerview reloadComponent:2];
                
                self.locate.industry2 = [[secondList objectAtIndex:row] objectForKey:@"name"];
                if ([thirdList count] > 0) {
                    self.locate.industry3 = [thirdList objectAtIndex:0];
                } else{
                    self.locate.industry3 = @"";
                }
                break;
            case 2:
                if ([thirdList count] > 0) {
                    self.locate.industry3 = [thirdList objectAtIndex:row];
                } else{
                    self.locate.industry3 = @"";
                }
                break;
            default:
                break;
        }
    }


    
    // 设置了以后执行代理   (这个是为了把这个字体弄出去显示在文本上)
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }
    
}


#pragma mark - animation

- (void)showInView:(UIView *) view
{
    CGFloat currentW = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat setheight = 200;
    
    self.frame = CGRectMake(0, view.frame.size.height, currentW, setheight);
   // self.frame = CGRectMake(0, 0, 414, 200);
    

    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - setheight, currentW, setheight);
    }];
    
}

- (void)cancelPicker
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
    
}


/**
 * 修改字体
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        //pickerLabel.minimumFontSize = 8.0;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    // Fill the label text here
    [pickerLabel setFont:[UIFont systemFontOfSize:15]];
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}



@end
