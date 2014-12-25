//
//  Utils.m
//  Common
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "Utils.h"
#import "BaseNavigationController.h"
#import "PopUpMovableDialogView.h"
#import "NSString+Expand.h"
#import "LoadingView.h"
static bool STATIC_SYN_INITPARAM;


NSString* documentDir;
NSString* documentSkipBackUpFileDir;
NSString* cachesDir;
NSString* cachesFileDir;
NSString* cachesFileImgDir;
NSString* systemVersion;

@implementation Utils

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
        cachesFileImgDir = [NSString stringWithFormat:@"%@/Img",cachesFileDir];
        systemVersion = [UIDevice currentDevice].systemVersion;
        [self fileExistsAtPath:documentSkipBackUpFileDir isDirectory:nil isCreated:YES];
        [self fileExistsAtPath:cachesFileDir isDirectory:nil isCreated:YES];
        [self fileExistsAtPath:cachesFileImgDir isDirectory:nil isCreated:YES];
        
        [self addSkipBackupAttributeToItemAtURL:documentSkipBackUpFileDir];
    }
    return true;
}

//==>文件和路径操作
/**
 当前路径是否有效
 path 路径
 isDir 是否是文件夹路径
 isCreated 是否创建文件夹
 */
+(BOOL) fileExistsAtPath:(NSString*)path isDirectory:(BOOL*) isDirectory isCreated:(BOOL) isCreated{
    NSFileManager *f = [NSFileManager defaultManager];
    if (!isDirectory) {
        BOOL b;
        if([f fileExistsAtPath:path isDirectory:&b]){
            return true;
        }
    }else{
        if([f fileExistsAtPath:path isDirectory:isDirectory]){
            return true;
        }
    }
    if (isCreated) {
        //如果不存在当前目录就创建
        [f createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return false;
    
}
//<==


+(UIWindow*) getWindow{
    return [UIApplication sharedApplication].keyWindow;
}
+(UIViewController*) getCurrentController{
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (!topWindow) {
        return nil;
    }
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows){
            if (topWindow.windowLevel == UIWindowLevelNormal)break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    if (!rootView) {
        return nil;
    }
    id nextResponder = [rootView nextResponder];
    if (!nextResponder) {
        return nil;
    }
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }else if([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil){
        result = topWindow.rootViewController;
    }else{
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result =  ((UINavigationController*)result).viewControllers.lastObject;
    }
    return result;
}

+(void) setRootController:(UIViewController*) controller window:(UIWindow *)window{
    UINavigationController *navnext = [[BaseNavigationController alloc]initWithRootViewController:controller];
    CGRect bounds = [UIScreen mainScreen].bounds;
    navnext.view.frame = bounds;
    navnext.view.backgroundColor = [UIColor clearColor];
    window.rootViewController = navnext;
    window.backgroundColor = [UIColor clearColor];
    [window makeKeyAndVisible];
    
}
+(void) setStatusBarHidden:(BOOL) barHidden{
    if ([[self getWindow].rootViewController isKindOfClass:[UINavigationController class]]) {
        [[UIApplication sharedApplication] setStatusBarHidden:barHidden];
        float offy = barHidden?20:0;
        CGRect r = CGRectMake(0, offy, boundsWidth(), boundsHeight()-offy);
        ((UINavigationController*)[self getWindow].rootViewController).view.frame = r;
    }
}



//==>
//计算文字占用的大小
+(CGSize) getBoundSizeWithTxt:(NSString*) txt font:(UIFont*) font size:(CGSize) size{
    CGSize _size;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    NSDictionary *attribute = @{NSFontAttributeName: font};
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine|
    NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    _size = [txt boundingRectWithSize:size options: options attributes:attribute context:nil].size;
#else
    _size = [txt sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#endif
    return _size;
}
/**
 计算指定字体对应的高度
 */
+(CGFloat) getFontHeightWithSize:(CGFloat) size fontName:(NSString*) fontName{
    CGFontRef customFont = CGFontCreateWithFontName((CFStringRef)(fontName));
    CGRect bbox = CGFontGetFontBBox(customFont); // return a box that can contain any char with this font
    int units = CGFontGetUnitsPerEm(customFont); // return how many glyph unit represent a system device unit
    CGFontRelease(customFont);
    CGFloat height = (((float)bbox.size.height)/((float)units))*size;
    return height;
}
+(CGFloat) getFontSizeWithHeight:(CGFloat) height fontName:(NSString*) fontName{
    CGFontRef customFont = CGFontCreateWithFontName((CFStringRef)(fontName));
    if (!customFont) {
        return 0;
    }
    CGRect bbox = CGFontGetFontBBox(customFont); // return a box that can contain any char with this font
    int units = CGFontGetUnitsPerEm(customFont); // return how many glyph unit represent a system device unit
    CGFontRelease(customFont);
    float suffx = CGFLOAT_MAX;
    for (int i=1; i<100; i++) {
        CGFloat _height = (((float)bbox.size.height)/((float)units))*i;
        _height = height-_height;
        if (suffx<ABS(_height)) {
            suffx = i-1;
            break;
        }
        suffx = _height;
    }
    return suffx;
}
//<==

//==>交互UI
+(void) showAlert:(NSString*) message Title:(NSString*) title{
    [[PopUpDialogVendorView alertWithMessage:message title:[NSString isEnabled:title]?title:NSLocalizedString(@"popup_default_title", nil) onclickBlock:nil buttonNames:NSLocalizedString(@"popup_default_confirm_name", nil),nil] show];
}
+(void) showLoading:(NSString*) message{
    [LoadingView show:message];
}
+(void) hiddenLoading{
    [LoadingView hidden];
}
//<==



//==>角度和弧度之间的转换
+(CGFloat) parseDegreesToRadians:(CGFloat) degrees{
    return ((degrees)*M_PI / 180.0);
}
+(CGFloat) parseRadiansToDegrees:(CGFloat) radians{
    return ((radians)*180.0 / M_PI);
}
//<==


+(BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)url
{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: url]);
    NSURL *URL = [NSURL fileURLWithPath:url];
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
