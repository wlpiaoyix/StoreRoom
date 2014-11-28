//
//  UILable+Param.h
//  wanxuefoursix
//
//  Created by wlpiaoyi on 14-10-29.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel(Param)
-(void) setParamTextColor:(UIColor *)textColor
            textAlignment:(NSTextAlignment) textAlignment
            numberOfLines:(int) numberOfLines
            font:(UIFont*) font;
@end
