//
//  Common.h
//  BasicUnit
//
//  Created by wlpiaoyi on 14/12/24.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const NSString* documentDir;
extern const NSString* documentSkipBackUpFileDir;
extern const NSString* cachesDir;
extern const NSString* cachesFileDir;
extern const NSString* cachesFileImgDir;
extern const NSString* systemVersion;


@interface Common : NSObject
//==>
float boundsWidth();
float boundsHeight();
float appWidth();
float appHeight();
//<==
long timeInterval();

+(bool) initParams;

//计算文字占用的大小
+(CGSize) getBoundSizeWithTxt:(NSString*) txt font:(UIFont*) font size:(CGSize) size;
/**
 计算指定字体对应的高度
 */
+(CGFloat) getFontHeightWithSize:(CGFloat) size fontName:(NSString*) fontName;
+(CGFloat) getFontSizeWithHeight:(CGFloat) height fontName:(NSString*) fontName;

@end

@interface CustomApplicationCommon : NSObject

@end

