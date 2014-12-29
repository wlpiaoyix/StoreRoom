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
#import "BaseWindow.h"
#import <AudioToolbox/AudioToolbox.h>

static bool STATIC_SYN_INITPARAM;


NSString* documentDir;
NSString* documentSkipBackUpFileDir;
NSString* cachesDir;
NSString* cachesFileDir;
NSString* cachesFileImgDir;
NSString* systemVersion;
bool flagStatusBarHidden;

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
        
        [DeviceOrientationListener getSingleInstance];
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
    if (![NSString isEnabled:path]) return false;
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
    
    UIView *rootView = [topWindow subviews].firstObject;
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

+(UIWindow*) setRootController:(UIViewController*) controller{
    UIWindow *window = [self getWindow];
    BOOL flag =false;
    if (!window) {
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        flag = true;
    }
    UINavigationController *navnext = [[BaseNavigationController alloc]initWithRootViewController:controller];
    CGRect bounds = [UIScreen mainScreen].bounds;
    navnext.view.frame = bounds;
    navnext.view.backgroundColor = [UIColor clearColor];
    window.rootViewController = navnext;
    window.backgroundColor = [UIColor clearColor];
    [window makeKeyAndVisible];
    return window;
}
+(void) setStatusBarHidden:(BOOL) barHidden{
    flagStatusBarHidden = barHidden;
    if ([[self getWindow].rootViewController isKindOfClass:[UINavigationController class]]) {
        [[UIApplication sharedApplication] setStatusBarHidden:flagStatusBarHidden];
        
        float offy = flagStatusBarHidden?0:20;
        CGRect r;
        switch ([DeviceOrientationListener getSingleInstance].orientation) {
                // Device oriented vertically, home button on the bottom
            case UIDeviceOrientationPortrait:{
                r = CGRectMake(0, offy, boundsWidth(), boundsHeight()-offy);
            }
                break;
                // Device oriented vertically, home button on the top
            case UIDeviceOrientationPortraitUpsideDown:{
                r = CGRectMake(0, 0, boundsWidth(), boundsHeight()-offy);
            }
                break;
                // Device oriented horizontally, home button on the right
            case UIDeviceOrientationLandscapeLeft:{
                r = CGRectMake(0, 0, boundsWidth()-offy, boundsHeight());
            }
                break;
                // Device oriented horizontally, home button on the left
            case UIDeviceOrientationLandscapeRight:{
                r = CGRectMake(offy, 0, boundsWidth()-offy, boundsHeight());
            }
                break;
            default:{
                r = CGRectMake(0, offy, boundsWidth(), boundsHeight()-offy);
            }
                break;
        }
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
+(void) showAlert:(NSString*) message title:(NSString*) title{
    PopUpDialogVendorView *alert = [PopUpDialogVendorView alertWithMessage:message title:[NSString isEnabled:title]?title:NSLocalizedStringFromTable(@"popup_default_title", @"Basic_Localizable", nil) onclickBlock:nil buttonNames:NSLocalizedStringFromTable(@"popup_default_confirm_name", @"Basic_Localizable", nil),nil];
    [alert show];
}
+(void) showLoading:(NSString*) message{
    if (message) {
        [LoadingView show:message];
    }else{
        [LoadingView show:NSLocalizedStringFromTable(@"loading_data_msg", @"Basic_Localizable", nil)];
    }
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

+(BOOL) soundWithPath:(NSString*) path isShake:(BOOL) isShake{
    if(![self fileExistsAtPath:path isDirectory:nil isCreated:NO])return false;
    
    SystemSoundID shortSound;
    // Create a file URL with this path
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // Register sound file located at that URL as a system sound
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url,
                                                    &shortSound);
    if (err != kAudioServicesNoError){
        NSLog(@"Could not load %@, error code: %d", url, (int)err);
        return false;
    }else{
        /*添加音频结束时的回调*/
        AudioServicesAddSystemSoundCompletion(shortSound, NULL, NULL, SoundFinished,(__bridge void *)(url));
        AudioServicesPlaySystemSound(shortSound);
        if(isShake)AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        CFRunLoopRun();
    }
    return true;
    
}

//当音频播放完毕会调用这个函数
static void SoundFinished(SystemSoundID soundID,void* sample){
    /*播放全部结束，因此释放所有资源 */
    AudioServicesDisposeSystemSoundID(soundID);
//    CFRelease(sample);
//    CFRunLoopStop(CFRunLoopGetCurrent());
}


@end
