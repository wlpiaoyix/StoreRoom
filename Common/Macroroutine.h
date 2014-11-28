//
//  CommonMacroroutine.h
//  Common
//
//  Created by wlpiaoyi on 14-10-7.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

//回调通用方法
typedef id (^CallBackMethod)(id key,...);
//百度开发都序列号
#define CM_BAIDU_AK @"13a8e69b95517ff6e09a69b91130db8b"
#define CM_UmengAppkey @"53fad58dfd98c506ed00929c"
//==>屏幕大小
#define BOUNDS_W [Common getBoundWidth]
#define BOUNDS_H [Common getBoundHeight]
//<==
//==>应用大小
#define APP_W [Common getAppWidth]
#define APP_H [Common getAppHeight]
//<==