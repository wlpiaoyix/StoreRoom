//
//  Common.h
//  Common
//
//  Created by wlpiaoyi on 14-9-29.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "ConfigManage.h"
#import "Macroroutine.h"
#import "NetWork.h"
#import "NSDate+convenience.h"
#import "NSMutableArray+convenience.h"
#import "UIColor+expanded.h"
#import "UIImage+Convenience.h"
#import "UIView+convenience.h"
#import "UIButton+Expand.h"
#import "UIWebView+convenience.h"
#import "NSString+Convenience.h"
#import "UILable+Convenience.h"
#import "ActivityIndicatorView.h"
#import "PopUpBasisView.h"
#import "PopUpDialogView.h"
#import "JSON.h"

//回调通用方法
typedef id (^CallBackMethod)(id key,...);

@class Common;
@interface Common : NSObject
+(void) initParams;
//==>
+(CGFloat) getBoundWidth;
+(CGFloat) getBoundHeight;
+(CGFloat) getAppWidth;
+(CGFloat) getAppHeight;
//<==
+(long) getTimeInterval;
+(CGFloat) getSystemVersion;

//==>
+(NSString*) getDocumentDir;
+(NSString*) getCachesDir;
+(NSString*) getCachesFileDir;
+(NSString*) getCachesFileImgDir;
//<==

+(UIWindow*) getWindow;
+(UIViewController*) getCurrentController;

//计算文字占用的大小
+(CGSize) getBoundingRectWithSize:(NSString*) txt font:(UIFont*) font size:(CGSize) size;
/**
 计算指定字体对应的高度
 */
+(CGFloat) getFontHeight:(NSString*) fontName Size:(CGFloat) size;
+(CGFloat) getFontSize:(NSString*) fontName height:(CGFloat) height;
/**
 计算出targetView对应在relativeView中得绝对位置
 */
+(CGRect) getAbsoluteRect:(UIView*) targetView relativelyView:(UIView*) relativelyView;
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)url;
/**
 当前路径是否有效
 path 路径
 isDir 是否是文件夹路径
 isCreated 是否创建文件夹
 */
+(BOOL) fileExistsAtPath:(NSString*)path isDirectory:(BOOL*) isDirectory isCreated:(BOOL) isCreated ;
//==>
+(void) setNavigationController:(UIViewController*) controller window:(UIWindow *)window;
+(void) setNavigationBarHidden:(BOOL) barHidden;
//==>角度和弧度之间的转换
+(CGFloat) parseDegreesToRadians:(CGFloat) degrees;
+(CGFloat) parseRadiansToDegrees:(CGFloat) radians;
//<==
//==>交互UI
+(void)showMessage:(NSString*) message Title:(NSString*) title;
+(void)showMessage:(NSString*) message Title:(NSString*) title Delegate:(id/*<PopUpDialogViewDelegate>*/) delegate Buttons:(NSString*) button,...;
+(void)showSheet:(NSString*) title TargetView:(UIView*) targetView Delegate:(id<UIActionSheetDelegate>) delegate ButtonNames:(id) buttonNames,...;
//<==
CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ);
@end
