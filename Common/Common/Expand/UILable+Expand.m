//
//  UILable+Convenience.m
//  超级考研
//
//  Created by wlpiaoyi on 14-9-11.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "UILable+Expand.h"
#import "UIView+Expand.h"
#import "Utils.h"
@implementation  UILabel(Expand)

-(void) setParamTextColor:(UIColor *)textColor textAlignment:(NSTextAlignment) textAlignment
            numberOfLines:(int) numberOfLines font:(UIFont*) font{
    self.numberOfLines = numberOfLines;
    self.textAlignment = textAlignment;
    self.textColor = textColor;
    self.font = font;
}

-(void) automorphismHeight{
    self.numberOfLines = 0;
    CGSize s = self.frameSize;
    CGSize sx = [Utils getBoundSizeWithTxt:self.text font:self.font size:CGSizeMake(s.width, 999)];
    sx.width = s.width;
    int width = sx.width;
    int height = sx.height+1;
    sx.width = width;
    sx.height = height;
    self.frameSize = sx;
}
-(void) automorphismWidth{
    CGSize s = self.frameSize;
    CGSize sx = [Utils getBoundSizeWithTxt:self.text font:self.font size:CGSizeMake(999, s.height)];
    sx.height = s.height;
    int width = sx.width+1;
    int height = sx.height;
    sx.width = width;
    sx.height = height;
    self.frameSize = sx;
}

@end
