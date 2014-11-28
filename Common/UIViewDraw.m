//
//  UIViewDraw.m
//  Common
//
//  Created by wlpiaoyi on 14-9-29.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "UIViewDraw.h"
#import "GraphicsContext.h"
#import "NetWorkHTTP.h"
#import "Common.h"
@implementation UIViewDraw

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, [Common getAppWidth], [Common getAppHeight]);
        self.contentSize = self.frame.size;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIColor *c = [UIColor redColor];
    const CGFloat lengths[] = {10,12};
    [GraphicsContext drawLineDash:nil StartPoint:CGPointMake(0, 220) EndPoint:CGPointMake(320, 220) LineColor:[c CGColor] LineWidth:1 Lengths:lengths Count:2];
    NetWorkHTTP *r = [NetWorkHTTP new];
    NSString *arg = @"4147F839B27B696DCEF02259BDC1BEA1464AF5E38A151C7B360300643F74D3031A0EADC21AE9E97A8E52BB609D770FEB5BC7A67C6B2099B060482B1A48F47673E74DBE375E01DD05A50AE9466B185E193A196F1E31B89C0DC4ED3B0671EDD64D555F5E7C0A5AA1402BF9A9C2BF4A304E3866925C5CB66BB9D09B84EC71ADC4946B4F058F318EB9E65F7B47F6E62DB22081B7A814141CE1F905673B78";//[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]*1000];
    [r setRequestString:@"http://127.0.0.1:8080"];
    [r addRequestHeadValue:@{@"content-type":@"application/x-www-form-urlencoded",@"sig":arg}];
    [r requestPOST:@{@"username":@"test71",@"password":@"wanxue去哦"}];
    [r startAsynRequest];
//
    [GraphicsContext drawRectangle:nil Point:CGPointMake(20, 180) FillColor:[[UIColor redColor] CGColor] StrokeColor:[[UIColor greenColor] CGColor] LineWidth:1 Width:30 Height:40];
//    [GraphicsContext drawRectangle:nil Point:CGPointMake(200, 180) FillColor:nil StrokeColor:[[UIColor greenColor] CGColor] LineWidth:1 Width:30 Height:40];
//    [GraphicsContext drawRectangle:nil Point:CGPointMake(150, 180) FillColor:nil StrokeColor:[[UIColor greenColor] CGColor] LineWidth:1 Width:30 Height:40];
    [GraphicsContext drawText:nil Text:@"adfadf" Font:[UIFont systemFontOfSize:20] Point:CGPointMake(30, 30) TextColor:[UIColor blueColor]];
    [GraphicsContext drawCircle:nil Point:CGPointMake(30, 30) FillColor:[[UIColor blueColor] CGColor] StrokeColor:[[UIColor whiteColor] CGColor] LineWidth:20 StartDegrees:-30 EndDegrees:80 Radius:50];
    [GraphicsContext drawColors:nil location:CGRectMake(20, 20, 40, 50) startColor:[UIColor whiteColor] endColor:[UIColor grayColor]];
//    [GraphicsContext drawEllipse:nil Rect:CGRectMake(10, 30, 80, 80) FillColor:nil StrokeColor:[[UIColor yellowColor] CGColor] LineWidth:5];
}


@end
