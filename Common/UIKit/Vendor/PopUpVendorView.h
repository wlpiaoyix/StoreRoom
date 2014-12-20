//
//  PopUpVendorView.h
//  Common
//
//  Created by wlpiaoyi on 14/12/18.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VendorMoveView.h"
@class PopUpVendorView;

typedef void (^dispatch_block_popup)(PopUpVendorView* vmv);

enum PopUpVendorViewAnimation {
    PopUpVendorViewAnimationNone,
    PopUpVendorViewAnimationSize
};

@interface PopUpVendorView : UIView
//弹出框
@property (nonatomic,strong,readonly) VendorMoveView *viewShow;
//弹出框所属的View
@property (nonatomic,strong) UIView *viewSuper;
//是否单击隐藏
@property (nonatomic) BOOL flagTouchHidden;
//在移动后是否回到中间
@property (nonatomic) BOOL flagBackToCenter;
//动画
@property (nonatomic) enum PopUpVendorViewAnimation animation;
//现在时的位置
@property (nonatomic) CGPoint pointShow;

-(void) initParam;

-(void) show;
-(void) close;

-(void) setBeforeShow:(dispatch_block_popup) callback;
-(void) setAfterShow:(dispatch_block_popup) callback;
-(void) setBeforeClose:(dispatch_block_popup) callback;
-(void) setAfterClose:(dispatch_block_popup) callback;

@end
