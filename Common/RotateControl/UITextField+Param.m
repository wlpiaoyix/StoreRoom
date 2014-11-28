//
//  UITextField+Param.m
//  wanxuefoursix
//
//  Created by wlpiaoyi on 14-10-30.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "UITextField+Param.h"

@implementation UITextField(Param)
-(void) setParamFont:(UIFont*) font placeholder:(NSString*) placeholder
        textColor:(UIColor*) textColor textAlignment:(NSTextAlignment) textAlignment
        keyboardType:(UIKeyboardType) keyboardType returnKeyType:(UIReturnKeyType) returnKeyType{
    self.placeholder = placeholder;
    self.font = font;
    self.textColor = textColor;
    self.textAlignment = textAlignment;
    if(keyboardType)self.keyboardType = keyboardType;
    if(returnKeyType)self.returnKeyType = returnKeyType;
}
-(void) setParamFont:(UIFont*) font placeholder:(NSString*) placeholder
           textColor:(UIColor*) textColor textAlignment:(NSTextAlignment) textAlignment{
    self.placeholder = placeholder;
    self.font = font;
    self.textColor = textColor;
    self.textAlignment = textAlignment;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
