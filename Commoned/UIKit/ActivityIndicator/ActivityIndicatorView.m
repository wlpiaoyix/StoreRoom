//
//  ActivityIndicatorView.m
//  Common
//
//  Created by wlpiaoyi on 14-4-17.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "ActivityIndicatorView.h"
#import "Common.h"

#define MyMBProgressHUDTAG  95793642
static UIView *LastActivityIndicatorView;
static id synShowHidden;
@implementation ActivityIndicatorView
+(void) initialize{
    synShowHidden = @"";
}
+ (void) showActivityIndicator:(NSString*) msg
{
    @synchronized(synShowHidden){
        UIViewController *topVC = [Common getCurrentController];
        topVC.view.userInteractionEnabled=NO;
        MBProgressHUD * myMBProgressHUD;
        if (LastActivityIndicatorView) {
            [self hideActivityIndicator];
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
+(void) setActivityIndicatoMsg:(NSString*)msg{
    @synchronized(synShowHidden){
        MBProgressHUD * myMBProgressHUD;
        if (LastActivityIndicatorView) {
            LastActivityIndicatorView.userInteractionEnabled=NO;
            myMBProgressHUD =(MBProgressHUD *)[LastActivityIndicatorView viewWithTag:MyMBProgressHUDTAG];
        }
        if (myMBProgressHUD) {
            myMBProgressHUD.labelText = msg;
        }else{
            [self showActivityIndicator:msg];
        }
    }
}

+ (void) hideActivityIndicator
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
