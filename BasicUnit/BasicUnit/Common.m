//
//  Common.m
//  BasicUnit
//
//  Created by wlpiaoyi on 14/12/24.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "Common.h"
static bool STATIC_SYN_INITPARAM;


NSString* documentDir;
NSString* documentSkipBackUpFileDir;
NSString* cachesDir;
NSString* cachesFileDir;
NSString* cachesFileImgDir;
NSString* systemVersion;


@implementation Common

+(void) initialize{
    [self initParams];
}


float boundsWidth(){
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}
float boundsHeight(){
    return CGRectGetHeight([UIScreen mainScreen].bounds);
}
float appWidth(){
    return CGRectGetWidth([UIScreen mainScreen].applicationFrame);
}
float appHeight(){
    return CGRectGetHeight([UIScreen mainScreen].applicationFrame);
}
long timeInterval(){
    time_t timer;
    timer=time(NULL);
    struct tm *tblock;
    tblock=localtime(&timer);
    printf("%s",asctime(tblock));
    return timer;
}

+(bool) initParams{
    @synchronized(self){
        if(STATIC_SYN_INITPARAM) return false;
        documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        documentSkipBackUpFileDir = [NSString stringWithFormat:@"%@/SkipBackUp",documentDir];
        cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        cachesFileDir = [NSString stringWithFormat:@"%@/File",cachesDir];
        cachesFileImgDir = [NSString stringWithFormat:@"%@/File",cachesFileDir];
        systemVersion = [UIDevice currentDevice].systemVersion;
    }
    return true;
}


+(UIWindow*) getWindow{
    return [UIApplication sharedApplication].keyWindow;
}
+(UIViewController*) getCurrentController{
}

//计算文字占用的大小
+(CGSize) getBoundSizeWithTxt:(NSString*) txt font:(UIFont*) font size:(CGSize) size{
}
/**
 计算指定字体对应的高度
 */
+(CGFloat) getFontHeightWithSize:(CGFloat) size fontName:(NSString*) fontName{
}
+(CGFloat) getFontSizeWithHeight:(CGFloat) height fontName:(NSString*) fontName{

}


@end
