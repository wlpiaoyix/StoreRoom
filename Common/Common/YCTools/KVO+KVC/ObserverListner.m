//
//  ObserverListner.m
//  ShiShang
//
//  Created by wlpiaoyi on 14/12/19.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "ObserverListner.h"

static ObserverListner *xObserverListner;
static id syn;

@interface ObserverListner()
@property (nonatomic,strong) NSMutableDictionary* dic;
@end

@implementation ObserverListner
+(void) initialize{
    syn = [NSObject new];
}

+(instancetype) getNewInstance{
    @synchronized(syn){
        if (!xObserverListner) {
            xObserverListner = [[ObserverListner alloc] init];
            xObserverListner.dic = [NSMutableDictionary new];
            __weak typeof(xObserverListner) weakol = xObserverListner;
            [xObserverListner addObserver:weakol forKeyPath:@"valueListner" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        }
    }
    return xObserverListner;
}
-(BOOL) mergeWithTarget:(id) target action:(SEL) action arguments:(NSArray*)arguments key:(NSString*) key{
    if ([target respondsToSelector:action]) {
        NSString *selstr = NSStringFromSelector(action);
        if (arguments) {
            [self.dic setObject:@{@"target":target,@"selstr":selstr,@"arguments":arguments} forKey:key];
        }else{
            [self.dic setObject:@{@"target":target,@"selstr":selstr} forKey:key];
        }
        return true;
    }
    return false;
}
-(void) removeWithKey:(NSString*) key{
    [self.dic removeObjectForKey:key];
}
-(void) setValueListner:(id)valueListner{
    _valueListner = valueListner;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    id kind = [change objectForKey:@"kind"];
    id old = [change objectForKey:@"old"];
    id new = [change objectForKey:@"new"];
    if(kind)printf("the observe kind hash code:%d\n",[kind hash]);
    if(old)printf("the observe old hash code:%d\n",[old hash]);
    if(new)printf("the observe new hash code:%d\n",[new hash]);
    
    NSDictionary *dicobj = [self.dic objectForKey:new];
    if (!dicobj)return;
    
    id target = [dicobj objectForKey:@"target"];
    SEL action = NSSelectorFromString([dicobj objectForKey:@"selstr"]);
    NSArray *arguments = [dicobj objectForKey:@"arguments"];
    if (![target respondsToSelector:action])return;
    
    //初始化NSMethodSignature对象
    NSMethodSignature *sig =[[target class] instanceMethodSignatureForSelector:action];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    //设置被调用的消息
    [invocation setSelector:action];
    //设置调用者也就是AsynInvoked的实例对象
    [invocation setTarget:target];
    //如果此消息有参数需要传入，那么就需要按照如下方法进行参数设置，需要注意的是，atIndex的下标必须从2开始。原因为：0 1 两个参数已经被target 和selector占用
    if(arguments&&[arguments count]){
        int index = 2;
        for (NSObject *argument in arguments) {
            [invocation setArgument:(__bridge void *)(argument) atIndex:index];    //执行方法
            index ++;
        }
    }
    //retain 所有参数，防止参数被释放dealloc
    [invocation retainArguments];
    //消息调用
    [invocation invoke];
    //获得返回值类型
    const char *returnType = sig.methodReturnType;
    //声明返回值变量
    id returnValue;
    if( !strcmp(returnType, @encode(void)) ){//如果没有返回值，也就是消息声明为void，那么
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
    
}

@end
