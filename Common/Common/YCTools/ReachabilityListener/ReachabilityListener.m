//
//  ReachabilityListener.m
//  wanxue
//
//  Created by wlpiaoyi on 14-9-16.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "ReachabilityListener.h"
#import "Utils.h"

static ReachabilityListener *xReachabilityListener;
static id synReachabilityListener;
@interface ReachabilityListener()
@property (strong,nonatomic) Reachability *hostReach;
@property (strong,nonatomic) id synlistener;
@property (strong,nonatomic) NSMutableArray *arrayListeners;
@end
@implementation ReachabilityListener
+(void) initialize{
    synReachabilityListener = @"";
}
+(ReachabilityListener*) getSingleInstance{
    @synchronized(xReachabilityListener){
        if (!xReachabilityListener) {
            xReachabilityListener = [ReachabilityListener new];
        }
    }
    return xReachabilityListener;
}
-(id) init{
    if(self=[super init]){
        [self statListener];
        self.synlistener = @"";
        self.arrayListeners = [NSMutableArray new];
    }
    return self;
}

-(void) statListener{
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
    [self.hostReach startNotifier];  //开始监听，会启动一个run loop
}

//网络链接改变时会调用的方法
-(void)reachabilityChanged:(NSNotification *)note{
    @synchronized(self.synlistener){
        Reachability *currReach = [note object];
        NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
        //对连接改变做出响应处理动作
        _networkStatus = [currReach currentReachabilityStatus];
        for (id<ReachabilityListenerDelegate> listener in self.arrayListeners) {
            switch (_networkStatus) {
                case NotReachable:{
                    if ([listener respondsToSelector:@selector(notReachable)]) {
                        [listener notReachable];
                    }
                }
                    // 没有网络连接
                    break;
                case ReachableViaWWAN:{
                    if ([listener respondsToSelector:@selector(reachableViaWWAN)]) {
                        [listener reachableViaWWAN];
                    }
                }
                    // 使用3G网络
                    break;
                case ReachableViaWiFi:{
                    if ([listener respondsToSelector:@selector(reachableViaWiFi)]) {
                        [listener reachableViaWiFi];
                    }
                }
                    // 使用WiFi网络
                    break;
            }
        }
    }
}
-(void) addListener:(id<ReachabilityListenerDelegate>) listener{
    @synchronized(self.synlistener){
        [self.arrayListeners addObject:listener];
    }
}
-(void) removeListenser:(id<ReachabilityListenerDelegate>) listener{
    @synchronized(self.synlistener){
        [self.arrayListeners removeObject:listener];
    }
}


@end
