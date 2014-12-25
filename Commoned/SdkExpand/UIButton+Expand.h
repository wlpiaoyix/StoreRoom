//
//  Button+Param.h
//  wanxuefoursix
//
//  Created by wlpiaoyi on 14-10-31.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton(Expand)
-(void) addTarget:(id) target action:(SEL) action;
-(void) setTitleImage:(NSString *)title forState:(UIControlState)state;
@end
