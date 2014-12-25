//
//  UIView+convenience.m
//
//  Created by Tjeerd in 't Veen on 12/1/11.
//  Copyright (c) 2011 Vurig Media. All rights reserved.
//

#import "UIView+convenience.h"
#import "MBProgressHUD.h"
@interface UIWebView(){
}
@end
@implementation UIWebView (convenience)

-(void) setJSMemeryLeak{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) webViewStopAll{
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    self.delegate = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
