//
//  Button+Param.m
//  wanxuefoursix
//
//  Created by wlpiaoyi on 14-10-31.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "Common.h"
#import "GraphicsContext.h"

@implementation UIButton(Expand)
-(void) addTarget:(id) target action:(SEL) action{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
-(void) setTitleImage:(NSString *)title forState:(UIControlState)state{
    NSString *fontName = self.titleLabel.font.fontName;
    int pxv = 2;
    float size = self.titleLabel.font.pointSize*pxv;
    UIFont *font = [UIFont fontWithName:fontName size:size];
    float width = [Common getBoundingRectWithSize:title font:font size:CGSizeMake(999, size)].width;
    CGContextRef cxt =  [GraphicsContext drawImageStart:CGRectMake(0, 0, self.frame.size.width*pxv, self.frame.size.height*pxv) fillColor:[[UIColor clearColor] CGColor]];
    [GraphicsContext drawText:cxt Text:title Font:font Point:CGPointMake((self.frame.size.width*pxv-width)/2, (self.frame.size.height*pxv-size*1.25)/2) TextColor:[self titleColorForState:state]];
    UIImage*image = [GraphicsContext drawImgeEnd:cxt];
    [self setContentMode:UIViewContentModeScaleAspectFit];
    [self setImage:image forState:state];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
