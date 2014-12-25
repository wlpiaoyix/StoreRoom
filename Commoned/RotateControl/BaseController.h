//
//  BaseController.h
//  super_gse
//
//  Created by wlpiaoyi on 14-7-15.
//  Copyright (c) 2014年 super_gse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "CommonNavigationController.h"

#define BAR_HEIGHT 44

typedef void (^CallBackKeyboardStart)(void);
typedef void (^CallBackKeyboardEnd)(CGRect keyBoardFrame);

@interface BaseController : UIViewController<MBProgressHUDDelegate,ProtocolNavigationController>{
@protected
    CallBackKeyboardStart  showStart;
    CallBackKeyboardStart hiddenStart;
    CallBackKeyboardEnd  showEnd;
    CallBackKeyboardEnd hiddenEnd;
}
@property (nonatomic, readonly) UITapGestureRecognizer* tapGestureRecognizer;
/**
 设置显示键盘的动画
 */
-(void) setSELShowKeyBoardStart:(CallBackKeyboardStart) start End:(CallBackKeyboardEnd) end;
/**
 设置隐藏键盘的动画
 */
-(void) setSELHiddenKeyBoardBefore:(CallBackKeyboardStart) start End:(CallBackKeyboardEnd) end;

-(void) excuteBeforeBackPrevious;
-(CATransition*) cATransitionBeforeBackPrevious;
-(void) backPreviousController;
-(void) backPreviousControllerToSuper:(UIViewController*) superController;
-(CATransition*) cATransitionBeforeGoNext;
-(void) goNextController:(UIViewController*) nextController;

@end
