//
//  PopUpVendorView.m
//  Common
//
//  Created by wlpiaoyi on 14/12/18.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "PopUpMovableView.h"
#import "Common.h"

static float STATIC_DISABLE_POINT_VALUE;
static UIColor *STATIC_DEFAULT_BACKGROUND_COLOR;


@interface PopUpMovableView(){
    dispatch_block_popup beforeShow;//显示之前要作的事情
    dispatch_block_popup afterShow;//显示之后要作的事情
    dispatch_block_popup beforeClose;//关闭之前要作的事情
    dispatch_block_popup afterClose;//关闭之后要作的事情
}
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic, strong) NSArray *subContaints;
@property (nonatomic, strong) NSArray *superContaints;
@property (nonatomic) CGSize sizeShow;

@end

@implementation PopUpMovableView

+(void) initialize{
    [super initialize];
    STATIC_DEFAULT_BACKGROUND_COLOR = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
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
    _animation = PopUpMovableViewAnimationSize;
    _pointShow.x = STATIC_DISABLE_POINT_VALUE+1;
    _pointShow.y = STATIC_DISABLE_POINT_VALUE+1;
    _flagBackToCenter = true;
    _flagTouchHidden = false;
    [self autoresizingMask_TBLRWH];
}

-(void) setViewSuper:(UIView *)viewSuper{
    _viewSuper = viewSuper;
    CGRect r = _viewSuper.frame;
    r.origin = CGPointMake(0, 0);
    self.frame = r;
}
-(void) setViewShow:(VendorMoveView *)viewShow{
    _sizeShow = viewShow.frameSize;
    _viewShow = viewShow;
}
-(void) removeCenterWithSubView:(UIView*) subView superView:(UIView*) superView{
    subView.translatesAutoresizingMaskIntoConstraints = YES;
    if (_subContaints) {
        for(NSArray *constraints in _subContaints){
            [subView addConstraints: constraints];
        }
    }
    if (_superContaints) {
        [superView removeConstraints:_superContaints];
    }
}
-(void) persistCenterWithSubView:(UIView*) subView superView:(UIView*) superView{
    [self removeCenterWithSubView:subView superView:superView];
    NSDictionary* viewVB = NSDictionaryOfVariableBindings(subView);
    _subContaints = @[
                      [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"[subView(%d)]",(int)subView.frameWidth] options:0 metrics:nil views:viewVB],
                      [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[subView(%d)]",(int)subView.frameHeight] options:0 metrics:nil views:viewVB]
                      ];
    //添加约束，使按钮在屏幕水平方向的中央
    _superContaints = @[
                        [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                        [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]
                        ];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    for(NSArray *constraints in _subContaints){
        [subView addConstraints: constraints];
    }
    [superView addConstraints:_superContaints];
    

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
            _viewSuper = [Utils getWindow];
        }
        CGRect r = self.frame;
        r.size = _viewSuper.frame.size;
        r.origin = CGPointMake(0, 0);
        self.frame = r;
        [self autoresizingMask_TBLRWH];
        
        _viewShow = (VendorMoveView*)view;
        r = _viewShow.frame;
        __weak typeof(self) weakself = self;
        [_viewShow setCallBackVendorTouchEnd:^(CGRect frame) {
            if (weakself.flagBackToCenter) {
                [UIView animateWithDuration:GALOB_ANIMATION_TIME animations:^{
                    CGPoint p;
                    
                    switch ([DeviceOrientationListener getSingleInstance].orientation) {
                            // Device oriented vertically, home button on the bottom
                        case UIDeviceOrientationPortrait:{
                            p = CGPointMake((weakself.frameWidth-weakself.viewShow.frameWidth)/2, (weakself.frameHeight-weakself.viewShow.frameHeight)/2);
                        }
                            break;
                            // Device oriented vertically, home button on the top
                        case UIDeviceOrientationPortraitUpsideDown:{
                            p = CGPointMake((weakself.frameWidth-weakself.viewShow.frameWidth)/2, (weakself.frameHeight-weakself.viewShow.frameHeight)/2);
                        }
                            break;
                            // Device oriented horizontally, home button on the right
                        case UIDeviceOrientationLandscapeLeft:{
                            p = CGPointMake((weakself.frameHeight-weakself.viewShow.frameWidth)/2, (weakself.frameWidth-weakself.viewShow.frameHeight)/2);
                        }
                            break;
                            // Device oriented horizontally, home button on the left
                        case UIDeviceOrientationLandscapeRight:{
                            p = CGPointMake((weakself.frameHeight-weakself.viewShow.frameWidth)/2, (weakself.frameWidth-weakself.viewShow.frameHeight)/2);
                        }
                            break;
                        default:{
                            p = CGPointMake((weakself.frameWidth-weakself.viewShow.frameWidth)/2, (weakself.frameHeight-weakself.viewShow.frameHeight)/2);
                        }
                            break;
                    }
                    
                    CGRect r = weakself.viewShow.frame;
                    r.origin = p;
                    weakself.viewShow.frame = r;
                }];
            }
        }];
    }
}

-(void) show{
    [[DeviceOrientationListener getSingleInstance] addListener:self];
    if (self.viewSuper==[Utils getWindow]) {
        //保证当前线程执行完成后才执行下一个线程
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, 1);
            self.viewShow.layer.transform = transformx;
        });
    }
    switch (self.animation) {
        case PopUpMovableViewAnimationSize:{
            [self showAnimationSize];
        }
            break;
        default:{
            [self showAnimationNone];
        }
            break;
    }
    switch ([DeviceOrientationListener getSingleInstance].orientation) {
            // Device oriented vertically, home button on the bottom
        case UIDeviceOrientationPortrait:{
            [self rotateViewExternal:0 animation:NO];
        }
            break;
            // Device oriented vertically, home button on the top
        case UIDeviceOrientationPortraitUpsideDown:{
            [self rotateViewExternal:180 animation:NO];
        }
            break;
            // Device oriented horizontally, home button on the right
        case UIDeviceOrientationLandscapeLeft:{
            [self rotateViewExternal:90 animation:NO];
        }
            break;
            // Device oriented horizontally, home button on the left
        case UIDeviceOrientationLandscapeRight:{
            [self rotateViewExternal:270 animation:NO];
        }
            break;
        default:{
        }
            break;
    }
}
-(void) close{
    switch (self.animation) {
        case PopUpMovableViewAnimationSize:{
            [self hiddenAnimationSize];
        }
            break;
        default:{
            [self hiddenAnimationNone];
        }
            break;
    }
    [[DeviceOrientationListener getSingleInstance] removeListenser:self];
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
    
    [UIView animateWithDuration:GALOB_ANIMATION_TIME animations:^{
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
    [UIView animateWithDuration:GALOB_ANIMATION_TIME animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 1, 1,1);
        self.viewShow.layer.transform = transform;
        if (self.viewSuper==[Utils getWindow]) {
            //保证当前线程执行完成后才执行下一个线程
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
            });
        }
        
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
        _viewShow.frameSize = _sizeShow;
    }
    if (self.superview!=_viewSuper) {
        [_viewSuper addSubview:self];
    }
    
    if (_pointShow.x<=STATIC_DISABLE_POINT_VALUE||_pointShow.y<=STATIC_DISABLE_POINT_VALUE) {
        [self removeCenterWithSubView:_viewShow superView:self];
        _viewShow.frameOrigin = _pointShow;
    }else{
        [self persistCenterWithSubView:_viewShow superView:self];
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



// Device oriented vertically, home button on the bottom
-(void) deviceOrientationPortrait{
    [self rotateViewExternal:0 animation:YES];
}
// Device oriented vertically, home button on the top
-(void) deviceOrientationPortraitUpsideDown{
    [self rotateViewExternal:180 animation:YES];
}
// Device oriented horizontally, home button on the right
-(void) deviceOrientationLandscapeLeft{
    [self rotateViewExternal:90 animation:YES];
}
// Device oriented horizontally, home button on the left
-(void) deviceOrientationLandscapeRight{
    [self rotateViewExternal:270 animation:YES];
}

-(void) rotateViewExternal:(int) degrees animation:(BOOL) animation{
    if (self.viewSuper==[Utils getWindow]) {
        [UIView animateWithDuration:animation?[DeviceOrientationListener getSingleInstance].duration:0.0f animations:^{
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, 1);
            transformx = CATransform3DRotate(transformx, [Utils parseDegreesToRadians:degrees], 0.0f, 0.0f, 1.0f);
            self.layer.transform = transformx;
            CGRect r = self.frame;
            r.size = CGSizeMake(boundsWidth(), boundsHeight());
            r.origin = CGPointMake(0, 0);
            self.frame = r;
        }];
    }
}

-(void) dealloc{
}


@end
