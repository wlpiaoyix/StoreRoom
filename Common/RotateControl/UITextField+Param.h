//
//  UITextField+Param.h
//  wanxuefoursix
//
//  Created by wlpiaoyi on 14-10-30.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField(Param)
-(void) setParamFont:(UIFont*) font placeholder:(NSString*) placeholder
           textColor:(UIColor*) textColor textAlignment:(NSTextAlignment) textAlignment;
-(void) setParamFont:(UIFont*) font
         placeholder:(NSString*) placeholder
           textColor:(UIColor*) textColor
       textAlignment:(NSTextAlignment) textAlignment
        keyboardType:(UIKeyboardType) keyboardType
       returnKeyType:(UIReturnKeyType) returnKeyType;

@end
