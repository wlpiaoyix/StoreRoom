//
//  Common.m
//  Common
//
//  Created by wlpiaoyi on 14-9-29.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "Common.h"
#import "CommonNavigationController.h"

@implementation Common
+(void) initialize{
}
+(void) initParams{
    BOOL isDirectory;
    [self fileExistsAtPath:[self getCachesFileDir] isDirectory:&isDirectory isCreated:YES];
    [self fileExistsAtPath:[self getCachesFileImgDir] isDirectory:&isDirectory isCreated:YES];
    [self addSkipBackupAttributeToItemAtURL:[self getCachesFileDir]];
    [self addSkipBackupAttributeToItemAtURL:[self getCachesFileImgDir]];
}
//==>
+(CGFloat) getBoundWidth{
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}
+(CGFloat) getBoundHeight{
    return CGRectGetHeight([UIScreen mainScreen].bounds);
}
+(CGFloat) getAppWidth{
    return CGRectGetWidth([UIScreen mainScreen].applicationFrame);
}
+(CGFloat) getAppHeight{
    return CGRectGetHeight([UIScreen mainScreen].applicationFrame);
}
+(long) getTimeInterval{
    time_t timer;
    timer=time(NULL);
    struct tm *tblock;
    tblock=localtime(&timer);
    printf("%s",asctime(tblock));
    return timer;
}
+(NSString*) getDocumentDir{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}
+(NSString*) getCachesDir{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
}
+(NSString*) getCachesFileDir{
    NSString* dir = [NSString stringWithFormat:@"%@/%@",[self getCachesDir],@"file"];
    return dir;
}
+(NSString*) getCachesFileImgDir{
    NSString* dir = [NSString stringWithFormat:@"%@/%@",[self getCachesFileDir],@"img"];
    return dir;
}
+(UIWindow*) getWindow{
    return [UIApplication sharedApplication].keyWindow;
}
+(UIViewController*) getCurrentController{
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows){
            if (topWindow.windowLevel == UIWindowLevelNormal)break;
        }
    }
    
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    
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
+(CGFloat) getSystemVersion{
    return [UIDevice currentDevice].systemVersion.floatValue;
}
+(BOOL) fileExistsAtPath:(NSString*)path isDirectory:(BOOL*) isDirectory isCreated:(BOOL) isCreated {
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
//计算文字占用的大小
+(CGSize) getBoundingRectWithSize:(NSString*) txt font:(UIFont*) font size:(CGSize) size{
    CGSize _size;
    
    if ([self getSystemVersion]>=7.0) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
        NSStringDrawingUsesLineFragmentOrigin |
        NSStringDrawingUsesFontLeading;
        _size = [txt boundingRectWithSize:size options: options attributes:attribute context:nil].size;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#endif
    } else {
        _size = [txt sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
#endif
    }
    return _size;
}
+(CGFloat) getFontHeight:(NSString*) fontName Size:(CGFloat) size{
    CGFontRef customFont = CGFontCreateWithFontName((CFStringRef)(fontName));
    CGRect bbox = CGFontGetFontBBox(customFont); // return a box that can contain any char with this font
    int units = CGFontGetUnitsPerEm(customFont); // return how many glyph unit represent a system device unit
    CGFontRelease(customFont);
    CGFloat height = (((float)bbox.size.height)/((float)units))*size;
    return height;
}

+(CGFloat) getFontSize:(NSString*) fontName height:(CGFloat) height{
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
+(CGRect) getAbsoluteRect:(UIView*) targetView relativelyView:(UIView*) relativelyView{
    UIView *superView = targetView;
    CGPoint p = CGPointMake(0, 0);
    while (superView) {
        p.x += superView.frame.origin.x;
        p.y += superView.frame.origin.y;
        superView = superView.superview;
        if (!relativelyView) {
            continue;
        }
        if (superView==relativelyView) {
            break;
        }
    }
    CGRect r = targetView.frame;
    r.origin = p;
    return r;
}
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

//==>
+(void) setNavigationController:(UIViewController*) controller window:(UIWindow *)window{
    UINavigationController *navnext = [[CommonNavigationController alloc]initWithRootViewController:controller];
    [navnext setNavigationBarHidden:YES];
    CGRect bounds = [UIScreen mainScreen].bounds;
    navnext.view.frame = bounds;
    navnext.view.backgroundColor = [UIColor clearColor];
    window.rootViewController = navnext;
    window.backgroundColor = [UIColor colorWithRed:0.208 green:0.588 blue:0.925 alpha:1];
    [window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
+(void) setNavigationBarHidden:(BOOL) barHidden{
    if ([[self getWindow].rootViewController isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController*)[self getWindow].rootViewController) setNavigationBarHidden:YES];
        CGRect r = ((UINavigationController*)[self getWindow].rootViewController).view.frame;
        r.origin.y = barHidden?0:20;
        r.size.height = BOUNDS_H;
        r.size.height -= r.origin.y;
        ((UINavigationController*)[self getWindow].rootViewController).view.frame = r;
    }
}

//==>角度和弧度之间的转换
+(CGFloat) parseDegreesToRadians:(CGFloat) degrees{
    return ((degrees)*M_PI / 180.0);
}
+(CGFloat) parseRadiansToDegrees:(CGFloat) radians{
    return ((radians)*180.0 / M_PI);
}
//<==

//==>交互UI
+(void)showMessage:(NSString*) message Title:(NSString*) title{
    [[PopUpDialogView initWithTitle:[NSString isEnabled:title]?title:@"提示"  message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil]show];
}
+(void)showMessage:(NSString*) message Title:(NSString*) title Delegate:(id<PopUpDialogViewDelegate>) delegate Buttons:(NSString*) button,...{
    va_list _list;
    va_start(_list, button);
    @try {
        PopUpDialogView *tempx = [PopUpDialogView initWithTitle:title  message:message  delegate:delegate cancelButtonTitle:button otherButtonTitles:va_arg( _list, NSString *),va_arg( _list, NSString *),va_arg( _list, NSString *),va_arg( _list, NSString *),va_arg( _list, NSString *),va_arg( _list, NSString *),va_arg( _list, NSString *),va_arg( _list, NSString *),nil];
        [tempx show];
    }
    @finally {
        va_end(_list);
    }
}
+(void)showSheet:(NSString*) title TargetView:(UIView*) targetView Delegate:(id<UIActionSheetDelegate>) delegate ButtonNames:(id) buttonNames,...{
    va_list arg_ptr;
    va_start(arg_ptr, buttonNames);
    @try {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:title
                                      delegate:delegate
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:buttonNames,va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),va_arg(arg_ptr, NSString*),nil];
        [actionSheet showInView:targetView];
    }
    @finally {
        va_end(arg_ptr);
    };
}
//<==


CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ) {
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ) {
//    CATransform3D rotate = CATransform3DMakeRotation(M_PI/3, 0, 1, 0);
//    if (t) {
//        t = rotate;
//    }
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}


@end
