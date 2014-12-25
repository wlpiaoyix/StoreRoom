//
//  GraphicsThumb.m
//  ShiShang
//
//  Created by wlpiaoyi on 14-11-5.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "GraphicsThumb.h"

@interface GraphicsThumb(){
@private
    UIImage * thumb;
    CALayer *thumbLayer;
    GraphicsLayer *graphicsLayer;
    
    CallBackGraphicsLayerDraw callBackGraphicsLayerDraw;
}
@property (nonatomic,strong) UIView *view;
@end

@implementation GraphicsThumb

+(GraphicsThumb*) GraphicsThumbWithView:(UIView*) view CallBackGraphicsLayerDraw:(CallBackGraphicsLayerDraw) callback{
    GraphicsThumb *gt = [GraphicsThumb new];
    gt.view = view;
    gt->callBackGraphicsLayerDraw = callback;
    return gt;
}

-(id) init{
    if(self=[super init]){
        [self setup];
    }
    return self;
}
-(void)setup{
//    _view.backgroundColor = [UIColor clearColor];
    _view.clipsToBounds = NO;
    thumbLayer = [CALayer layer];
    thumbLayer.contentsScale = [UIScreen mainScreen].scale;
    thumbLayer.contents = (id) thumb.CGImage;
    thumbLayer.frame = CGRectMake(_view.frame.size.width  - thumb.size.width, 0, thumb.size.width, thumb.size.height);
    thumbLayer.hidden = YES;
    [_view.layer addSublayer:thumbLayer];
}
-(void) setCallBackGraphicsLayerDraw:(CallBackGraphicsLayerDraw) callback{
    callBackGraphicsLayerDraw = callback;
}

-(void) executDisplay:(id) userInfo{
    [_view setNeedsLayout];
    if(graphicsLayer){
        [graphicsLayer removeFromSuperlayer];
    }else{
        graphicsLayer = [GraphicsLayer layer];
        [graphicsLayer setCallBackGraphicsLayerDraw:callBackGraphicsLayerDraw];
        
    }
    graphicsLayer.userInfo = userInfo;
    graphicsLayer.contentsScale = [UIScreen mainScreen].scale;
    graphicsLayer.frame = _view.bounds;
    graphicsLayer.masksToBounds = NO;
    graphicsLayer.backgroundColor = [[UIColor clearColor] CGColor];
    [_view.layer addSublayer:graphicsLayer];
    [graphicsLayer displayIfNeeded];
    [graphicsLayer setNeedsDisplay];
    
}


#pragma mark - Touch Events
- (void)moveThumbToPosition:(double)angle {
    CGRect rect = thumbLayer.frame;
    CGPoint center = CGPointMake(_view.bounds.size.width, _view.bounds.size.height);
    angle -= (M_PI/2);
    
    rect.origin.x = center.x + 75 * cosf(angle) - (rect.size.width);
    rect.origin.y = center.y + 75 * sinf(angle) - (rect.size.height);
    
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    thumbLayer.frame = rect;
    
    [CATransaction commit];
}
@end
