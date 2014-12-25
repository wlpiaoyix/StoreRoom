//
//  GraphicsLayer.m
//  ShiShang
//
//  Created by wlpiaoyi on 14-11-5.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "GraphicsLayer.h"
@interface GraphicsLayer(){
@private
    CallBackGraphicsLayerDraw callBackGraphicsLayerDraw;
    id syncallback;
}
@end
@implementation GraphicsLayer
-(id) init{
    if(self=[super init]){
        syncallback = [NSObject new];
    }
    return self;
}
-(void) setCallBackGraphicsLayerDraw:(CallBackGraphicsLayerDraw)callback{
    @synchronized(syncallback){
        callBackGraphicsLayerDraw = callback;
    }
}
-(void) drawInContext:(CGContextRef)ctx{
    @synchronized(syncallback){
        if (callBackGraphicsLayerDraw) {
            callBackGraphicsLayerDraw(ctx,_userInfo);
        }
    }
}
@end
