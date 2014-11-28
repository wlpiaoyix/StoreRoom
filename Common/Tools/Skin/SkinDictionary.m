//
//  SkinDictionary.m
//  Common
//
//  Created by wlpiaoyi on 14-10-27.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "SkinDictionary.h"
#import "Common+Expand.h"

#define DEFAULTCOLORPACKEGE @"colorpackge";

static NSString *STATICDEFAULTPATH;
static NSString *STATICZIPPATH;
static id SYNSINGLEINSTACNCE;
static SkinDictionary* xSkinDictionary;
static NSMutableArray *arraySkinFiles;
@implementation SkinDictionary{
    NSMutableDictionary *dicColors;
}
+(void) initialize{
    SYNSINGLEINSTACNCE = [NSObject new];
    STATICDEFAULTPATH = [[NSBundle mainBundle] resourcePath];
}
+(void) setSkinZipPath:(NSString*) path{
    @synchronized(SYNSINGLEINSTACNCE){
        if ([NSString isEnabled:path]) {
            STATICZIPPATH = path;
            arraySkinFiles = [NSMutableArray new];
            [self allContentsOfDirectoryAtPath:path parentPath:nil files:arraySkinFiles];
        }
    }
}
+(void) allContentsOfDirectoryAtPath:(NSString*) path parentPath:(NSString*) parentPath files:(NSMutableArray*) files{
    if (!files) {
        return;
    }
    NSString *temppath = [NSString stringWithFormat:@"%@/%@",path,parentPath?parentPath:@""];
    NSArray *tempfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:temppath error:nil];
    if (tempfiles&&[tempfiles count]) {
        for (NSString *tempfile in tempfiles) {
            [self allContentsOfDirectoryAtPath:temppath parentPath:tempfile files:files];
        }
    }else if([NSString isEnabled:parentPath]){
        [files addObject:[NSString stringWithFormat:@"/%@",parentPath]];
    }
}
+(NSString*) getSkinZipPath{
    return STATICZIPPATH;
}
+(SkinDictionary*) getSingleInstance{
    @synchronized(SYNSINGLEINSTACNCE){
        if (![NSString isEnabled:STATICZIPPATH]) {
            [SkinDictionary setSkinZipPath:STATICDEFAULTPATH];
        }
        if (!xSkinDictionary) {
            xSkinDictionary = [SkinDictionary new];
        }
    }
    return xSkinDictionary;
}
-(id) init{
    
    if (self=[super init]) {
        NSString *colorpackge = [self getSkinPathPackgePath];
        dicColors = [NSMutableDictionary new];
        if (![[NSFileManager defaultManager] fileExistsAtPath:colorpackge isDirectory:nil]) {
            // set the orignal datetime property
            NSDate* orgDate = nil;
            
            //{{ thanks to brad.eaton for the solution
            NSDateComponents *dc = [[NSDateComponents alloc] init];
            
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSGregorianCalendar];
            
            orgDate = [gregorian dateFromComponents:dc] ;
            //}}
            
            NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate];
            
            NSData *data = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:colorpackge contents:data attributes:attr];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:colorpackge isDirectory:nil]) {NSError *erro;
            NSMutableString *colorDatas = [NSMutableString stringWithContentsOfURL:[NSURL fileURLWithPath:colorpackge] encoding:NSUTF8StringEncoding error:&erro];
            if (erro) {
                NSLog(@"304875 erro:%@",[erro debugDescription]);
            }else{
                NSArray *array = [colorDatas componentsSeparatedByString:@"\n"];
                for (NSString *colordic in array) {
                    NSArray *arrayColor = [colordic componentsSeparatedByString:@":"];
                    if (arrayColor&&[arrayColor count]>=2) {
                        NSString *key = [arrayColor objectAtIndex:0];
                        UIColor *value = [self parsetStringToColor:[arrayColor objectAtIndex:1]];
                        [dicColors setObject:value forKey:key];
                    }
                }
            }
        }
    }
    return self;
}
-(NSString*) getSkinPathPackgePath{
    NSString *key = DEFAULTCOLORPACKEGE;
    NSString*keypath = [self getSkinPath:key];
    return keypath;
}
-(NSString*) getSkinPath:(NSString*) key{
    NSString*keypath;
    @synchronized(SYNSINGLEINSTACNCE){
        if (![NSString isEnabled:STATICZIPPATH]) {
            return nil;
        }
        for (NSString *temp in arraySkinFiles) {
            if ([temp stringEndWith:[NSString stringWithFormat:@"/%@",key]]) {
                keypath = temp;
            }
        }
        if (![NSString isEnabled:keypath]) {
            return nil;
        }
        keypath = [NSString stringWithFormat:@"%@%@",STATICZIPPATH,keypath];
    }
    BOOL b;
    if (![Common fileExistsAtPath:keypath isDirectory:&b isCreated:NO]) {
        keypath = [NSString stringWithFormat:@"%@/%@",STATICDEFAULTPATH,key];
    }
    if (![Common fileExistsAtPath:keypath isDirectory:&b isCreated:NO]) {
        return nil;
    }
    return keypath;
}
-(UIColor*) getSkinColor:(NSString*) key{
    if([key stringEndWith:@".info"]){
        NSString*keypath = [self getSkinPath:key];
        if (![NSString isEnabled:keypath]) {
            return nil;
        }
        NSError *erro;
        NSString *str = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:keypath] encoding:NSUTF8StringEncoding error:&erro];
        if (erro) {
            return nil;
        }
        return [self parsetStringToColor:str];
    }else{
        return [dicColors objectForKey:key];
    }
    return nil;
}
-(UIImage*) getSkinImage:(NSString*) key{
    NSString*keypath = [self getSkinPath:key];
    if (![NSString isEnabled:keypath]) {
        return nil;
    }
    UIImage *image;
    if ([key stringEndWith:@".png"]||[key stringEndWith:@".jpg"]) {
        image = [UIImage imageWithContentsOfFile:keypath];
    }else{
        UIColor *color = [self getSkinColor:key];
        if (!color) {
            return nil;
        }
        image = [UIImage imageWithColor:color];
    }
    return image;
   
}
-(BOOL) setSkinImageView:(UIImageView*) imageView key:(NSString*) key{
    if (!imageView) {
        return false;
    }
    UIImage *image = [self getSkinImage:key];
    if (!image) {
        return false;
    }
    imageView.image = image;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    return true;
}
-(UIColor*) parsetStringToColor:(NSString*) colorstr{
    NSArray *array = [[[colorstr componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@","];
    if ([array count]<3) {
        return nil;
    }
    
    float red = 1.0f;
    float green = 1.0f;
    float blue = 1.0f;
    float alpha = 1.0f;
    if ([[array firstObject] stringStartWith:@"C"]) {
        red = ((NSString*) [array objectAtIndex:0]).floatValue;
        green = ((NSString*) [array objectAtIndex:1]).floatValue;
        blue = ((NSString*) [array objectAtIndex:2]).floatValue;
        if ([array count]>3) {
            alpha = ((NSString*) [array objectAtIndex:3]).floatValue;
        }
    }else{
        red = ((NSString*) [array objectAtIndex:0]).floatValue/255.0f;
        green = ((NSString*) [array objectAtIndex:1]).floatValue/255.0f;
        blue = ((NSString*) [array objectAtIndex:2]).floatValue/255.0f;
        if ([array count]>3) {
            alpha = ((NSString*) [array objectAtIndex:3]).floatValue/255.0f;
        }
    }
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return color;
}
@end
