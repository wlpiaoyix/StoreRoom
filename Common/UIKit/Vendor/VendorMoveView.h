//
//  VendorMoveView.h
//  ShiShang
//
//  Created by wlpiaoyi on 14-11-15.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VendorMoveSubViewDelegate <NSObject>
@end

typedef void (^CallBackVendorTouchOpt)(CGRect frame);
@interface VendorMoveView : UIView<VendorMoveSubViewDelegate>
-(void) setCallBackVendorTouchBegin:(CallBackVendorTouchOpt) begin;
-(void) setCallBackVendorTouchMove:(CallBackVendorTouchOpt) move;
-(void) setCallBackVendorTouchEnd:(CallBackVendorTouchOpt) end;
@end
