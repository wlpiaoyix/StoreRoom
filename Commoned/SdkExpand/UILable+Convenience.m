//
//  UILable+Convenience.m
//  超级考研
//
//  Created by wlpiaoyi on 14-9-11.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "UILable+Convenience.h"
#import "UIView+convenience.h"
#import "Common.h"
@implementation  UILabel(Convenience)

-(void) automorphismHeight{
    self.numberOfLines = 0;
    CGSize s = self.frameSize;
    CGSize sx = [Common getBoundingRectWithSize:self.text font:self.font size:CGSizeMake(s.width, 999)];
    sx.width = s.width;
    int width = sx.width;
    int height = sx.height+1;
    sx.width = width;
    sx.height = height;
    self.frameSize = sx;
}
-(void) automorphismWidth{
    CGSize s = self.frameSize;
    CGSize sx = [Common getBoundingRectWithSize:self.text font:self.font size:CGSizeMake(999, s.height)];
    sx.height = s.height;
    int width = sx.width+1;
    int height = sx.height;
    sx.width = width;
    sx.height = height;
    self.frameSize = sx;
}

@end
