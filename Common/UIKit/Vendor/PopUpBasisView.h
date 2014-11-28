//
//  PopUpBasisView.h
//  DXAlertView
//
//  Created by wlpiaoyi on 14-4-9.
//  Copyright (c) 2014年 xiekw. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PopUpBasisView : UIView{
@protected
    UIView *contextView;//用来装加入进来的视图
    UIView *floatingview;//覆盖视图
    CGRect contextBaseFrame;//原本的frame
    UIButton *closeButton;//关闭按钮
    bool hasCloseButton;//是否要显示关闭按钮
    dispatch_block_t afterCloseBolock;//关闭之后要作的事情
    CGPoint viewbasepoint;
}  
-(void) initParam;
-(void) initParamWithTargetView:(UIView*) targetView;
-(void) setHasCloseButton:(bool) hasCloseButton;
-(void) setAfterCloseBolock:(dispatch_block_t) afterCloseBolock;
-(void) close;
-(void) show;
@end
