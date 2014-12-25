//
//  ConfigManage.m
//  sunsharp_epub
//
//  Created by wlpiaoyi on 14-6-29.
//  Copyright (c) 2014年 sunsharp. All rights reserved.
//

#import "ConfigManage.h"
@implementation ConfigManage
+(void) setConfigValue:(id) value Key:(NSString*) key{
    NSUserDefaults *usrDefauls=[NSUserDefaults standardUserDefaults];
    [usrDefauls setValue:value forKey:key];
    [usrDefauls synchronize];
}
+(id) getConfigValue:(NSString*) key{
    NSUserDefaults *usrDefauls=[NSUserDefaults standardUserDefaults];
    return  [usrDefauls valueForKey:key];
}
+(void) removeConfigValue:(NSString*) key{
    NSUserDefaults *usrDefauls=[NSUserDefaults standardUserDefaults];
    [usrDefauls removeObjectForKey:key];
}
+(void) removeALL{
    NSUserDefaults *usrDefauls=[NSUserDefaults standardUserDefaults];
    NSDictionary *datas = [usrDefauls dictionaryRepresentation];
    NSArray *keys = [datas allKeys];
    for (NSString *key in keys) {
        [usrDefauls removeObjectForKey:key];
    }
}
@end
