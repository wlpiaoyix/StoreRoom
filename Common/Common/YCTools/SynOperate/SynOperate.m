//
//  SynOperate.m
//  wanxue
//
//  Created by wlpiaoyi on 14-9-11.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "SynOperate.h"
#import "Common.h"
@interface SynOperate(){
    CallBackSynOperate callBack;
    CallBackSynOperate callBackStart;
    CallBackSynOperate callBackEnd;
}
@property (nonatomic,assign) id<SynOperateDelegate> delegate;
@property (nonatomic,strong) NSThread *thread;
@end
@implementation SynOperate
+(SynOperate*) initWithDelegate:(id<SynOperateDelegate>) delegate{
    SynOperate *so = [SynOperate new];
    so.delegate = delegate;
    return so;
}
+(SynOperate*) initWIthCallBack:(CallBackSynOperate) _callBack_ CallBackStart:(CallBackSynOperate) _callBackStart_ CallBackEnd:(CallBackSynOperate) _callBackEnd_{
    SynOperate *so = [SynOperate new];
    so->callBack = _callBack_;
    so->callBackEnd = _callBackEnd_;
    so->callBackStart = _callBackStart_;
    return so;
}

+(SynOperate*) initWithDelegate:(id<SynOperateDelegate>) delegate UserInfo:(id) userInfo{
    SynOperate *so = [SynOperate new];
    so.delegate = delegate;
    so->_userInfo = userInfo;
    return so;
}
+(SynOperate*) initWIthCallBack:(CallBackSynOperate) _callBack_ CallBackStart:(CallBackSynOperate) _callBackStart_ CallBackEnd:(CallBackSynOperate) _callBackEnd_ UserInfo:(id) userInfo{
    SynOperate *so = [SynOperate new];
    so->callBack = _callBack_;
    so->callBackEnd = _callBackEnd_;
    so->callBackStart = _callBackStart_;
    so->_userInfo = userInfo;
    return so;
}
-(void) start{
    if(self.waitmsg){
        [LoadingView show:self.waitmsg];
    }
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(synexcute) object:nil];
    [self.thread start];
}
-(void) synexcute{
    __weak typeof(self) weakself = self;
//    dispatch_queue_t syn_queue;
//    syn_queue = dispatch_queue_create("com.wlpiaoyi.syn.synchronize",nil);
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//    });

    if (self.delegate) {
        [weakself.delegate operate:weakself];
    }else if(callBackStart){
        callBackStart(weakself);
    }
    if (weakself.delegate) {
        callBack(weakself);
    }else if(callBack){
        callBack(weakself);
    }
    if(self.waitmsg){
        [LoadingView hidden];
    }
    if (self.delegate) {
        [weakself.delegate operate:weakself];
    }else if(callBackEnd){
        callBackEnd(weakself);
    }
}
@end
