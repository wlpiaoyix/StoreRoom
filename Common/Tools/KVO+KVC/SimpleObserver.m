//
//  SimpleObserver.m
//  超级考研
//
//  Created by wlpiaoyi on 14-9-9.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "SimpleObserver.h"
#import "ReflectClass.h"
static id staticsynsoinstance;
static SimpleObserver* xSimpleObserver;
@interface SimpleObserver()
@property (nonatomic,strong) id synsoaddobs;
@property (nonatomic,strong) NSMutableDictionary *dic;
@end
@implementation SimpleObserver
+(void) initialize{
    staticsynsoinstance = @"";
}
+(SimpleObserver*) getSingleInstance{
    @synchronized(staticsynsoinstance){
        if (!xSimpleObserver) {
            xSimpleObserver = [SimpleObserver new];
            xSimpleObserver.dic = [NSMutableDictionary new];
            xSimpleObserver.synsoaddobs = @"";
        }
    }
    return xSimpleObserver;
}
-(BOOL) addObserverx:(id) observer action:(SEL) action excute:(id) excute excuteNum:(int) excuteNum userInfo:(id)userInfo forKeyPath:(NSString*) keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if (![observer respondsToSelector:action]) {
        return false;
    }
    @synchronized(self.synsoaddobs){
        NSString *key = [NSString stringWithFormat:@"%li_%@",[observer hash],keyPath];
        [self removeObserverx:observer forKeyPath:keyPath];
        __weak typeof(excute) weakexcute = excute;
        NSString *selstr = NSStringFromSelector(action);
        [self.dic setObject:@{ @"excute":weakexcute, @"action":selstr,@"keyPath":keyPath,@"userInfo":userInfo} forKey:key];
        [observer addObserver:self forKeyPath:keyPath options:options context:context];
    }
    return true;
}
-(BOOL) removeObserverx:(id) observer forKeyPath:(NSString*) keyPath{
    NSNumber *key = [NSNumber numberWithInteger:[observer hash]];
    NSDictionary *json = [self.dic objectForKey:key];
    if (json) {
        [self.dic removeObjectForKey:key];
        [observer removeObserver:self forKeyPath:keyPath];
    }
    return false;
}
-(BOOL) removeObserverx:(id) observer{
    NSNumber *key = [NSNumber numberWithInteger:[observer hash]];
    NSDictionary *json = [self.dic objectForKey:key];
    if (json) {
        [self.dic removeObjectForKey:key];
        [observer removeObserver:self];
    }
    return false;
}
//观察者需要实现的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *key = [NSString stringWithFormat:@"%li_%@",[object hash],keyPath];
    NSDictionary *json = [self.dic objectForKey:key];
    id userInfo = [json objectForKey:@"userInfo"];
    NSString *action = [json objectForKey:@"action"];
    SEL sel = NSSelectorFromString(action);
    id excute = [json objectForKey:@"excute"];
    if (!excute) {
        [self removeObserverx:object forKeyPath:keyPath];
        return;
    }
    if (![object respondsToSelector:sel]) {
        [self removeObserverx:object forKeyPath:keyPath];
        return;
    }
    NSNumber *excuteNum = [json objectForKey:@"excuteNum"];
    //初始化NSMethodSignature对象
    NSMethodSignature *sig =[[object class] instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    //设置被调用的消息
    [invocation setSelector:sel];
    //设置调用者也就是AsynInvoked的实例对象
    [invocation setTarget:object];
    //如果此消息有参数需要传入，那么就需要按照如下方法进行参数设置，需要注意的是，atIndex的下标必须从2开始。原因为：0 1 两个参数已经被target 和selector占用
    [invocation setArgument:&userInfo atIndex:2];    //执行方法
    //retain 所有参数，防止参数被释放dealloc
    [invocation retainArguments];
    //消息调用
    [invocation invoke];
    //获得返回值类型
    const char *returnType = sig.methodReturnType;
    //声明返回值变量
    id returnValue;
    if( !strcmp(returnType, @encode(void)) ){//如果没有返回值，也就是消息声明为void，那么returnValue=nil
        returnValue =  nil;
    }else if(!strcmp(returnType, @encode(id)) ){//如果返回值为对象，那么为变量赋值
        [invocation getReturnValue:&returnValue];
    }else{ //如果返回值为普通类型NSInteger  BOOL
        //返回值长度
        NSUInteger length = [sig methodReturnLength];
        //根据长度申请内存
        void *buffer = (void *)malloc(length);
        //为变量赋值
        [invocation getReturnValue:buffer];
        //以下代码为参考:具体地址我忘记了，等我找到后补上，(很对不起原作者)
        if( !strcmp(returnType, @encode(BOOL)) ) {
            returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
        } else if( !strcmp(returnType, @encode(NSInteger)) ){
            returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
        } else {
            returnValue = [NSValue valueWithBytes:buffer objCType:returnType];
        }
        free(buffer);
    }
    if (excuteNum.intValue<0) {
        return;
    }
    if (excuteNum.intValue==0) {
        [self removeObserverx:object forKeyPath:keyPath];
        return;
    }
    excuteNum = [NSNumber numberWithInt:excuteNum.intValue-1];
    [json setValue:excuteNum forKey:@"excuteNum"];
}
@end
