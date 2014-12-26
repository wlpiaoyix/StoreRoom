//
//  BaseWindow.m
//  Common
//
//  Created by wlpiaoyi on 14/12/26.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "BaseWindow.h"
#import "Utils.h"
#import "UIView+Expand.h"

@implementation BaseWindow

-(id) init{
    if (self=[super init]) {
        [self initparams];
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self initparams];
    }
    return self;
}
-(id) initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initparams];
    }
    return self;
}

-(void) initparams{
    self.viewExternal = [[UIView alloc] initWithFrame:self.frame];
    self.viewExternal.backgroundColor = [UIColor clearColor];
    [self.viewExternal setCornerRadiusAndBorder:5 BorderWidth:5 BorderColor:[UIColor redColor]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor =[UIColor greenColor];
    [self.viewExternal addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* views = NSDictionaryOfVariableBindings(view);
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[view(60)]" options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(60)]" options:0 metrics:nil views:views]];
    
    
    //添加约束，使按钮在屏幕水平方向的中央
    [self.viewExternal addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewExternal attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.viewExternal addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewExternal attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [[DeviceOrientationListener getSingleInstance] addListener:self];
}
-(UIView*) viewExternal{
    @synchronized(_viewExternal){
        [_viewExternal removeFromSuperview];
        [self addSubview:_viewExternal];
    }
    return _viewExternal;
}


// Device oriented vertically, home button on the bottom
-(void) deviceOrientationPortrait{
    [self rotateViewExternal:0];
}
// Device oriented vertically, home button on the top
-(void) deviceOrientationPortraitUpsideDown{
    [self rotateViewExternal:180];
}
// Device oriented horizontally, home button on the right
-(void) deviceOrientationLandscapeLeft{
    [self rotateViewExternal:90];
}
// Device oriented horizontally, home button on the left
-(void) deviceOrientationLandscapeRight{
    [self rotateViewExternal:270];
}

-(void) rotateViewExternal:(int) degrees{
    [UIView animateWithDuration:GALOB_ANIMATION_TIME animations:^{
        CATransform3D transformx = CATransform3DIdentity;
        transformx = CATransform3DScale(transformx, 1, 1, 1);
        transformx = CATransform3DRotate(transformx, [Utils parseDegreesToRadians:degrees], 0.0f, 0.0f, 1.0f);
        self.viewExternal.layer.transform = transformx;
        CGRect r = self.viewExternal.frame;
        r.size = CGSizeMake(boundsWidth(), boundsHeight());
        r.origin = CGPointMake(0, 0);
        self.viewExternal.frame = r;
    }];
}


@end
