//
//  SimpleObserver.h
//  超级考研
//
//  Created by wlpiaoyi on 14-9-9.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleObserver : NSObject
+(SimpleObserver*) getSingleInstance;
/**
 添加观察者和执行者
 */
#pragma observer 观察者
#pragma action观察者响应的方法
#pragma excute 执行者
#pragma excuteNum 执行次数/-1无限次
#pragma userInfo 用户信息,将在响应的方法中给出
-(BOOL) addObserverx:(id) observer action:(SEL) action excute:(id) excute excuteNum:(int) excuteNum  userInfo:(id)userInfo forKeyPath:(NSString*) keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
-(BOOL) removeObserverx:(id) observer forKeyPath:(NSString*) keyPath;
-(BOOL) removeObserverx:(id) observer;
@end
