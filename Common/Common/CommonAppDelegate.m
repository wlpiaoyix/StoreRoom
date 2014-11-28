//
//  CommonAppDelegate.m
//  Common
//
//  Created by wlpiaoyi on 14-9-28.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "CommonAppDelegate.h"
#import "ZipArchive.h"
#import "UIImage+Convenience.h"
#import "UIViewDraw.h"
#import "ColorMatrix.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement+expanded.h"
#import "NetWorkDownLoad.h"

@implementation CommonAppDelegate

+ (void) mergeXMLDocument:(NSData*) mergeXML TagetXML:(NSData*) tagetXML
{
    
    //使用NSData对象初始化
    NSError *error;
    GDataXMLDocument *mergedoc = [[GDataXMLDocument alloc] initWithData:mergeXML  options:0 error:&error];
    if (error)  printf("merge erro:%s",[error.description UTF8String]);
    error = nil;
    GDataXMLDocument *tagetdoc = [[GDataXMLDocument alloc] initWithData:tagetXML  options:0 error:&error];
    [mergedoc setCharacterEncoding:@"UTF-8"];
    [tagetdoc setCharacterEncoding:@"UTF-8"];

    if (error) printf("merge erro:%s",[error.description UTF8String]);
    //获取根节点
    GDataXMLElement *mergeRootElement = [mergedoc rootElement];    //获取根节点
    GDataXMLElement *targetRootElement = [tagetdoc rootElement];
    
    [GDataXMLElement mergeXMLElement:mergeRootElement TargetElement:targetRootElement Compare:^BOOL(const GDataXMLElement *mergeElement, const GDataXMLElement *targetElement) {
        NSString *mergeIdvalue = [mergeElement attributeForName:@"id"].stringValue;
        NSString *targetIdvalue = [targetElement attributeForName:@"id"].stringValue;
        return [mergeIdvalue isEqualToString:targetIdvalue];
    }];
    NSData *data = [tagetdoc XMLData];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(string);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UIViewDraw *v = [UIViewDraw new];
    v.frame = self.window.frame;
    [self.window addSubview:v];
    
    NetWorkDownLoad *n = [NetWorkDownLoad new];
    n.downLoadString = @"http://yinyueshiting.baidu.com/data2/music/123297915/1201250291413518461128.mp3?xcode=ca8584c01dc8c2ce22828897c3b293b7a6a03c85c06f4409";
    [n resumeDownLoad];
    
    NSString *zippath = [[NSBundle mainBundle] pathForResource:@"3715" ofType:@"zip"];
    
    NSString *xml1 = [[NSBundle mainBundle] pathForResource:@"dict1" ofType:@"xml"];
    NSString *xml2 = [[NSBundle mainBundle] pathForResource:@"dict2" ofType:@"xml"];
    ZipArchive *zip = [ZipArchive new];
    
    [zip createZipFile:zippath append:2];
    [zip addFileToZip:xml2 newname:@"1.1/tgg.xml"];
//    [zip addFileToZip:@"" newname:@"1.1/5.xml"];
//    [zip addFileToZip:xml1 newname:@"testzip2.xml"];
    [zip closeZipFile];
//    double time = [[NSDate date] timeIntervalSince1970];
//    NSArray *arraypath = [zip getAllUnzipPath];
//    NSLog(@"%f",[[NSDate date] timeIntervalSince1970]-time);
//    [Common fileExistsAtPath:[NSString stringWithFormat:@"%@/mp3",[Common getDocumentDir]] IsDir:YES IsCreated:YES];
//    
//    time = [[NSDate date] timeIntervalSince1970];
//    NSData *data = [zip getUnzipFile:[arraypath lastObject]];
//    NSLog(@"%f",(long)[[NSDate date] timeIntervalSince1970]-time);
//    NSString *path = [NSString stringWithFormat:@"%@/%@",[Common getDocumentDir],[arraypath lastObject]];
//    [data writeToFile:path atomically:YES];
//    time = [[NSDate date] timeIntervalSince1970];
//    data = [zip getUnzipFile:[arraypath objectAtIndex:[arraypath count]-4]];
//    NSLog(@"%f",(long)[[NSDate date] timeIntervalSince1970]-time);
//    path = [NSString stringWithFormat:@"%@/%@",[Common getDocumentDir],[arraypath objectAtIndex:[arraypath count]-4]];
//    [data writeToFile:path atomically:YES];
//    
//    time = [[NSDate date] timeIntervalSince1970];
//    data = [zip getUnzipFile:[arraypath objectAtIndex:[arraypath count]-3]];
//    NSLog(@"%f",(long)[[NSDate date] timeIntervalSince1970]-time);
//    path = [NSString stringWithFormat:@"%@/%@",[Common getDocumentDir],[arraypath objectAtIndex:[arraypath count]-3]];
//    [data writeToFile:path atomically:YES];
//    [zip closeUnzipFile];
    //获取工程目录的xml文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    filePath = [[NSBundle mainBundle] pathForResource:@"dict2" ofType:@"xml"];
    NSData *xmlData2 = [[NSData alloc] initWithContentsOfFile:filePath];
    [CommonAppDelegate mergeXMLDocument:xmlData TagetXML:xmlData2];
    UIFont *f = [UIFont systemFontOfSize:18];
    CGFontRef customFont = CGFontCreateWithFontName((CFStringRef)(f.fontName));
    CGRect bbox = CGFontGetFontBBox(customFont);           // return a box that can contain any char with this font
    int units = CGFontGetUnitsPerEm(customFont);           // return how many glyph unit represent a system device unit
    CGFontRelease(customFont);
    CGFloat height = (((float)bbox.size.height)/((float)units))*12;
//    ZipArchive *zip = [ZipArchive new];
//    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    path = [NSBundle pathForResource:@"Tests" ofType:@"zip"  inDirectory:path];
//    [zip UnzipOpenFile:path];
//    NSData *data = [zip getUnzipFile:path FilePath:@"CommonTests/CommonTests.m"];
//    [data writeToFile:[NSString stringWithFormat:@"%@/adfasd.m",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject] atomically:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
