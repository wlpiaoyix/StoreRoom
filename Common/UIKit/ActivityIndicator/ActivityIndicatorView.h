//
//  ActivityIndicatorView.h
//  Common
//
//  Created by wlpiaoyi on 14-4-17.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "MBProgressHUD.h"

@interface ActivityIndicatorView : NSObject
+ (void) showActivityIndicator:(NSString*) msg;
+(void) setActivityIndicatoMsg:(NSString*)msg;
+ (void) hideActivityIndicator;
@end
