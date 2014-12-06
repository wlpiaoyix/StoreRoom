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
#import "GDataXMLNode.h"
#import "GDataXMLElement+expanded.h"
#import "NetWorkDownLoad.h"
#import "SimplePikerView.h"

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
    
    SimplePikerView *p = [SimplePikerView new];
    CGRect r = p.frame;
    r.size.width = 100;
    r.size.height = 300;
    p.frame = r;
    
    [self.window addSubview:p];
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
