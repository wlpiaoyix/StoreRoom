//
//  ActivityIndicatorView.h
//  Common
//
//  Created by wlpiaoyi on 14-4-17.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "MBProgressHUD.h"

@interface LoadingView : NSObject
+ (void) show:(NSString*) msg;
+(void) setMsg:(NSString*)msg;
+ (void) hidden;
@end
