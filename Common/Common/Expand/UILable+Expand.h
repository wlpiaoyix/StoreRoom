//
//  UILable+Convenience.h
//  超级考研
//
//  Created by wlpiaoyi on 14-9-11.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel(Expand)
-(void) automorphismHeight;
-(void) automorphismWidth;
-(void) setParamTextColor:(UIColor *)textColor
            textAlignment:(NSTextAlignment) textAlignment
            numberOfLines:(int) numberOfLines
                     font:(UIFont*) font;
@end
