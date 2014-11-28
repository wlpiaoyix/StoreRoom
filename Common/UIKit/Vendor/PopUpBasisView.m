//
//  PopUpBasisView.m
//  DXAlertView
//
//  Created by wlpiaoyi on 14-4-9.
//  Copyright (c) 2014年 xiekw. All rights reserved.
//


#import "PopUpBasisView.h"
#import "Common.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define invStopTime 0.02f
#else
#define invStopTime 0.01f
#endif
@interface PopUpBasisView()
@property (retain,nonatomic) UIView *targetView;
@end
@implementation PopUpBasisView{
}
-(void) initParam{
    [self initParamWithTargetView:nil];
}
-(void) initParamWithTargetView:(UIView*) targetView{
    CGRect frame;
    if (targetView) {
        self.targetView = targetView;
        frame = self.targetView.frame;
        frame.origin.x = frame.origin.y = 0;
    }else{
        frame = CGRectMake(0, 0, [Common getBoundWidth] , [Common getBoundHeight]);
    }
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithRed:0.129 green:0.137 blue:0.169 alpha:0.6];
    //<==
    //==>
    self->contextView = [UIView new];
    self->contextView.backgroundColor = [UIColor clearColor];
    self->contextView.tag = arc4random() % 999999999;
    [self->contextView setClipsToBounds:YES];
    self->floatingview = [UIView new];
    self->floatingview.backgroundColor = [UIColor clearColor];
    [self addSubview:self->contextView];
    //<==
    //==>
    UIButton *xButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [xButton setImage:[UIImage imageNamed:@"btn_close_normal.png"] forState:UIControlStateNormal];
    [xButton setImage:[UIImage imageNamed:@"btn_close_selected.png"] forState:UIControlStateHighlighted];
    xButton.frame = CGRectMake(0, 0, 32, 32);
    [xButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self->closeButton = xButton;
}

-(void) setHasCloseButton:(bool) _hasCloseButton_ {
    self->hasCloseButton = _hasCloseButton_;
    if (self->closeButton) {
        [self->closeButton setHidden:!self->hasCloseButton];
        UIView *view = self->closeButton.superview;
        if (view) {
            [self->closeButton removeFromSuperview];
            [view addSubview:self->closeButton];
        }
    }
}
-(void) setAfterCloseBolock:(dispatch_block_t) _afterCloseBolock_{
    self->afterCloseBolock = _afterCloseBolock_;
}
-(void) close{
    [self removeFromSuperview];
    if(self->afterCloseBolock)self->afterCloseBolock();
}
- (void)show{
    CALayer  *layer =  self.layer;
    CATransform3D transform =  layer.transform;
    transform.m43 = INT64_MAX;
    layer.transform = transform;
    if (self.targetView) {
        [self.targetView addSubview:self];
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
}
-(void) addSubview:(UIView *)view{
    if (view.hash==self->contextView.hash) {
        [super addSubview:self->contextView];
    }else{
        for (UIView *_view_ in [self->contextView subviews]) {
            [_view_ removeFromSuperview];
        }
        
        CGRect r = self->contextView.frame;
        CGRect r2 = view.frame;
        
        r.size.width = r2.size.width+r2.origin.x*2;
        r.size.height = r2.size.height+r2.origin.y*2;
        r.origin.x = (self.frame.size.width-r.size.width)/2;
        r.origin.y = (self.frame.size.height-r.size.height)/2;
        viewbasepoint = r.origin;
        
        self->contextView.frame = r;
        [self->contextView addSubview:view];
        
        if (self->hasCloseButton) {
            CGRect rb = self->closeButton.frame;
            rb.origin.y = 0;
            rb.origin.x = r.size.width-rb.size.width;
            self->closeButton.frame = rb;
            [self->contextView addSubview:self->closeButton];
        }
        self->contextBaseFrame = self->contextView.frame;
        self->floatingview.frame = CGRectMake(0, 0, self->contextBaseFrame.size.width, self->contextBaseFrame.size.height);
    }
}

CGPoint point;
#pragma mark - TouchesMoved
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect r = self->contextView.frame;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (r.origin.x<=touchPoint.x&&r.origin.y<=touchPoint.y&&(r.origin.x+r.size.width)>touchPoint.x&&(r.origin.y+r.size.height)>touchPoint.y) {
        float offx = touchPoint.x-point.x;
        float offy = touchPoint.y-point.y;
        if (r.origin.x+offx<0) {
            r.origin.x = 0;
        }else if(r.origin.x+r.size.width+offx>self.frame.size.width){
            r.origin.x = self.frame.size.width-r.size.width;
        }else{
            r.origin.x += offx;
        }
        if (r.origin.y+offy<=0){
            r.origin.y = 0;
        }else if(r.origin.y+r.size.height+offy>self.frame.size.height){
            r.origin.y = self.frame.size.height-r.size.height;
        }else{
            r.origin.y += offy;
        }
        self->contextView.frame = r;
        point = touchPoint;
    };
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    point = touchPoint;
    [super touchesBegan:touches withEvent:event];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.2f animations:^{
        CGRect r = self->contextView.frame;
        r.origin = viewbasepoint;
        self->contextView.frame = r;
    }];
}

- (void)removeFromSuperview{
    [self hiddenRorateSize];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    [super willMoveToSuperview:newSuperview];
    [self showRotateSize];
}
-(void) hiddenRorateSize{
    [self->contextView addSubview:self->floatingview];
    self->contextView.alpha = 1;
    CATransform3D transformx = CATransform3DIdentity;
    transformx = CATransform3DScale(transformx, 1, 1, INT32_MAX);
    self->contextView.layer.transform = transformx;
    [UIView animateWithDuration:0.5f animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 0.001, 0.001, INT32_MAX);
        self->contextView.alpha = 0;
        self->contextView.layer.transform = transform;
    } completion:^(BOOL finished) {
        self->contextView.alpha = 1;
        [self->floatingview removeFromSuperview];
        [super removeFromSuperview];
    }];
}
-(void) hiddenRorateCircle{
    dispatch_queue_t queue;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        float alpha = 1.0f;
        float offx = 1.0f,offy = 1.0f;
        float angle = 0;
        while (alpha >= 0.0f) {
            self->contextView.alpha = alpha;
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, offx, offy, INT32_MAX);
            transformx = CATransform3DRotate(transformx, [Common parseDegreesToRadians:angle], 0.0f, 0.0f, 1.0f);
            //保证当前线程执行完成后才执行下一个线程
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                self->contextView.layer.transform = transformx;
            });
            alpha -= 0.1f;
            offx -= 0.1f;
            offy -= 0.1f;
            angle += 40;
            if (angle>360) {
                angle = angle-360;
            }
            [NSThread sleepForTimeInterval:invStopTime];
        }
        //不保证当前线程执行完成后才执行下一个线程
        dispatch_async(dispatch_get_main_queue(), ^{
            self->contextView.alpha = 1;
            [super removeFromSuperview];
        });
    });
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
    printf("auto release");
#else
    dispatch_release(queue);
#endif
}
-(void) showRotateSize{
    self->contextView.frame = self->contextBaseFrame;
    [self->contextView addSubview:self->floatingview];
    self->contextView.alpha = 0;
    CATransform3D transformx = CATransform3DIdentity;
    transformx = CATransform3DScale(transformx, 0, 0, INT32_MAX);
    self->contextView.layer.transform = transformx;
    [UIView animateWithDuration:0.5f animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 1, 1, INT32_MAX);
        self->contextView.layer.transform = transform;
        self->contextView.alpha = 1;
    } completion:^(BOOL finished) {
        self->contextView.frame = self->contextBaseFrame;
        [self->floatingview removeFromSuperview];
    }];
}
-(void) showRotateCircle{
    self->contextView.frame = self->contextBaseFrame;
    [self->contextView addSubview:self->floatingview];
    dispatch_queue_t queue;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue,^{
        float alpha = 0;
        float offx = 0.0f,offy = 0.0f;
        float angle = 40;
        while (alpha<= 1.0f) {
            self->contextView.alpha = alpha;
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, offx, offy, INT32_MAX);
            transformx = CATransform3DRotate(transformx, [Common parseDegreesToRadians:angle], 0.0f, 0.0f, 1.0f);
            //保证当前线程执行完成后才执行下一个线程
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                self->contextView.layer.transform = transformx;
            });
            alpha += 0.1f;
            offx += 0.1f;
            offy += 0.1f;
            angle -= 40;
            if (angle<0) {
                angle = angle+360;
            }
            [NSThread sleepForTimeInterval:invStopTime];
        }
        //不保证当前线程执行完成后才执行下一个线程
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, INT32_MAX);
            transformx = CATransform3DRotate(transformx, [Common parseDegreesToRadians:0], 0.0f, 0.0f, 1.0f);
            self->contextView.layer.transform = transformx;
            self->contextView.frame = self->contextBaseFrame;
            self->contextView.alpha = 1;
            [self->floatingview removeFromSuperview];
        });
    });
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
    printf("auto release");
#else
    dispatch_release(queue);
#endif
}
@end
