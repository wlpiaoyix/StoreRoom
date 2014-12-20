//
//  PopUpVendorView.m
//  Common
//
//  Created by wlpiaoyi on 14/12/18.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "PopUpVendorView.h"
#import "Common.h"
#import "UIView+AutoRect.h"

static float STATIC_DISABLE_POINT_VALUE;
static UIColor *STATIC_DEFAULT_BACKGROUND_COLOR;


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define invStopTime 0.02f
#else
#define invStopTime 0.01f
#endif

@interface PopUpVendorView(){
    dispatch_block_popup beforeShow;//显示之前要作的事情
    dispatch_block_popup afterShow;//显示之后要作的事情
    dispatch_block_popup beforeClose;//关闭之前要作的事情
    dispatch_block_popup afterClose;//关闭之后要作的事情
}
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@end

@implementation PopUpVendorView

+(void) initialize{
    [super initialize];
    STATIC_DEFAULT_BACKGROUND_COLOR = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    STATIC_DISABLE_POINT_VALUE = 99999.99999f;
}

-(id) init{
    if (self=[super init]) {
        [self initParam];
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self initParam];
    }
    return self;
}
-(id) initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initParam];
    }
    return self;
}
-(void) setFlagTouchHidden:(BOOL)flagTouchHidden{
    _flagTouchHidden = flagTouchHidden;
    if (!_tapGestureRecognizer) {
        return;
    }
    if (_flagTouchHidden) {
        [self addGestureRecognizer:_tapGestureRecognizer];
    }else{
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
}

-(void) initParam{
    self.backgroundColor = STATIC_DEFAULT_BACKGROUND_COLOR;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    _animation = PopUpVendorViewAnimationSize;
    _pointShow.x = STATIC_DISABLE_POINT_VALUE-1;
    _pointShow.y = STATIC_DISABLE_POINT_VALUE-1;
    _flagBackToCenter = true;
    _flagTouchHidden = false;
    [self autoresizingMask_TBLRWH];
    [self setViewSuper:[Common getWindow]];
}

-(void) setViewSuper:(UIView *)viewSuper{
    _viewSuper = viewSuper;
    CGRect r = _viewSuper.frame;
    r.origin = CGPointMake(0, 0);
    self.frame = r;
}

-(void) addSubview:(UIView *)view{
    @synchronized(self){
        if (![view isKindOfClass:[VendorMoveView class]]) {
            return;
        }
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
        [view setAutoresizesSubviews:NO];
        [view setAutoresizingMask:UIViewAutoresizingNone];
        [super addSubview:view];
        
        
        if (!_viewSuper) {
            _viewSuper = [Common getWindow];
        }
        CGRect r = self.frame;
        r.size = _viewSuper.frame.size;
        r.origin = CGPointMake(0, 0);
        self.frame = r;
        [self autoresizingMask_TBLRWH];
        
        _viewShow = (VendorMoveView*)view;
        r = _viewShow.frame;
        if (_pointShow.x<=STATIC_DISABLE_POINT_VALUE||_pointShow.y<=STATIC_DISABLE_POINT_VALUE) {
            _pointShow = CGPointMake((self.frame.size.width-r.size.width)/2, (self.frame.size.height-r.size.height)/2);
        }
        __weak typeof(self) weakself = self;
        [_viewShow setCallBackVendorTouchEnd:^(CGRect frame) {
            if (weakself.flagBackToCenter) {
                [UIView animateWithDuration:0.25f animations:^{
                    CGPoint p = CGPointMake((weakself.viewSuper.frame.size.width-weakself.viewShow.frame.size.width)/2, (weakself.viewSuper.frame.size.height-weakself.viewShow.frame.size.height)/2);
                    CGRect r = weakself.viewShow.frame;
                    r.origin = p;
                    weakself.viewShow.frame = r;
                }];
            }
        }];
    }
}

-(void) show{
    CGRect r = _viewShow.frame;
    r.origin = _pointShow;
    _viewShow.frame = r;
    switch (self.animation) {
        case PopUpVendorViewAnimationSize:{
            [self showAnimationSize];
        }
            break;
        default:{
            [self showAnimationNone];
        }
            break;
    }
}
-(void) close{
    switch (self.animation) {
        case PopUpVendorViewAnimationSize:{
            [self hiddenAnimationSize];
        }
            break;
        default:{
            [self hiddenAnimationNone];
        }
            break;
    }
}

-(void) hiddenAnimationNone{
    if (beforeClose) {
        __weak typeof(self) weakself = self;
        beforeClose(weakself);
    }
    [self setHiddenBeforeStatus];
    [self setHiddenAfterStatus];
    [self.viewShow removeFromSuperview];
    [super removeFromSuperview];
    if (afterClose) {
        __weak typeof(self) weakself = self;
        afterClose(weakself);
    }
}
-(void) hiddenAnimationSize{
    if (beforeClose) {
        __weak typeof(self) weakself = self;
        beforeClose(weakself);
    }
    [self setHiddenBeforeStatus];
    [self setShowAfterStatus];
    
    [UIView animateWithDuration:0.5f animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 0.001, 0.001,1);
        self.viewShow.alpha = 0;
        self.viewShow.layer.transform = transform;
    } completion:^(BOOL finished) {
        [self setHiddenAfterStatus];
        [self.viewShow removeFromSuperview];
        [super removeFromSuperview];
        if (afterClose) {
            __weak typeof(self) weakself = self;
            afterClose(weakself);
        }
    }];
}
-(void) showAnimationNone{
    if (beforeShow) {
        __weak typeof(self) weakself = self;
        beforeShow(weakself);
    }
    [self setShowBeforeStatus];
    [self setShowAfterStatus];
    if (afterShow) {
        __weak typeof(self) weakself = self;
        afterShow(weakself);
    }
}
-(void) showAnimationSize{
    if (beforeShow) {
        __weak typeof(self) weakself = self;
        beforeShow(weakself);
    }
    [self setShowBeforeStatus];
    [self setHiddenAfterStatus];
    [UIView animateWithDuration:0.5f animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 1, 1,1);
        self.viewShow.layer.transform = transform;
        self.viewShow.alpha = 1;
    } completion:^(BOOL finished) {
        [self setShowAfterStatus];
        if (afterShow) {
            __weak typeof(self) weakself = self;
            afterShow(weakself);
        }
    }];
}

-(void) setShowBeforeStatus{
    if (!_viewSuper) {
        return;
    }
    if(_viewShow.superview!=self){
        [_viewShow removeFromSuperview];
        [super addSubview:_viewShow];
    }
    if (self.superview!=_viewSuper) {
        [_viewSuper addSubview:self];
    }
}
-(void) setShowAfterStatus{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DScale(transform, 1, 1,1);
    self.viewShow.layer.transform = transform;
    self.viewShow.alpha = 1;
}
-(void) setHiddenBeforeStatus{
    if (!_viewSuper) {
        return;
    }
    if(_viewShow.superview!=self){
        [_viewShow removeFromSuperview];
        [super addSubview:_viewShow];
    }
    if (self.superview!=_viewSuper) {
        [_viewSuper addSubview:self];
    }
}
-(void) setHiddenAfterStatus{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DScale(transform, 0.001, 0.001,1);
    self.viewShow.alpha = 0;
    self.viewShow.layer.transform = transform;
}

-(void) setBeforeShow:(dispatch_block_popup) callback{
    beforeShow = callback;
}
-(void) setAfterShow:(dispatch_block_popup) callback{
    afterShow = callback;
}
-(void) setBeforeClose:(dispatch_block_popup) callback{
    beforeClose = callback;
}
-(void) setAfterClose:(dispatch_block_popup) callback{
    afterClose = callback;
}

@end
