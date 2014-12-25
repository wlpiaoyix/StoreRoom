//
//  ReflectClass.h
//  Common
//
//  Created by wlpiaoyi on 14-5-9.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ReflectClass : NSObject
+(bool) setPropertyValue:(id)value selName:(NSString *) selName Target:(id) target;
+(id) getPropertyValue:(NSString*) selName Target:(id) target;
+(NSMutableArray*) getAllPropertys:(Class) clazz;
+(SEL) getSEL:(NSString*) selName Target: (id) target;
+(SEL) getMethodSEL:(NSString*) methodName Target:(id) target;

@end
