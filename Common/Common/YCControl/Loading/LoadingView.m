//
//  ActivityIndicatorView.m
//  Common
//
//  Created by wlpiaoyi on 14-4-17.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "Common.h"

#define MyMBProgressHUDTAG  95793642
static UIView *LastActivityIndicatorView;
static id synShowHidden;
@implementation LoadingView
+(void) initialize{
    synShowHidden = @"";
}
+ (void) show:(NSString*) msg
{
    @synchronized(synShowHidden){
        UIViewController *topVC = [Utils getCurrentController];
        topVC.view.userInteractionEnabled=NO;
        MBProgressHUD * myMBProgressHUD;
        if (LastActivityIndicatorView) {
            [self hidden];
        }
        if (!myMBProgressHUD) {
            myMBProgressHUD = [[MBProgressHUD alloc] initWithView:topVC.view];
            myMBProgressHUD.tag=MyMBProgressHUDTAG;
        }
        [topVC.view addSubview:myMBProgressHUD];
        [topVC.view bringSubviewToFront:myMBProgressHUD];
        myMBProgressHUD.labelText = msg?msg:@"正在加载...";
        [myMBProgressHUD show:YES];
        LastActivityIndicatorView = topVC.view;
    }
}
+(void) setMsg:(NSString*)msg{
    @synchronized(synShowHidden){
        MBProgressHUD * myMBProgressHUD;
        if (LastActivityIndicatorView) {
            LastActivityIndicatorView.userInteractionEnabled=NO;
            myMBProgressHUD =(MBProgressHUD *)[LastActivityIndicatorView viewWithTag:MyMBProgressHUDTAG];
        }
        if (myMBProgressHUD) {
            myMBProgressHUD.labelText = msg;
        }else{
            [self show:msg];
        }
    }
}

+ (void) hidden
{
    @synchronized(synShowHidden){
        LastActivityIndicatorView.userInteractionEnabled=YES;
        MBProgressHUD * tempMBProgressHUD =(MBProgressHUD *)[LastActivityIndicatorView viewWithTag:MyMBProgressHUDTAG];
        if (tempMBProgressHUD!=nil) {
            [tempMBProgressHUD removeFromSuperview];
        }
    }
    
}


@end
