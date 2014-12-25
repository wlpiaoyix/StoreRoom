//
//  UILable+Param.m
//  wanxuefoursix
//
//  Created by wlpiaoyi on 14-10-29.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "UILabel+Param.h"

@implementation UILabel(Param)
-(void) setParamTextColor:(UIColor *)textColor textAlignment:(NSTextAlignment) textAlignment
       numberOfLines:(int) numberOfLines font:(UIFont*) font{
    self.numberOfLines = numberOfLines;
    self.textAlignment = textAlignment;
    self.textColor = textColor;
    self.font = font;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
