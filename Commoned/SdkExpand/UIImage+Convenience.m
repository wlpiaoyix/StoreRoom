//
//  UIImage+Convenience.m
//  AKSL-189-Msp
//
//  Created by AKSL-td on 13-12-3.
//  Copyright (c) 2013年 AKSL. All rights reserved.
//

#import "UIImage+Convenience.h"
#import <Foundation/Foundation.h>

@implementation UIImage (Convenience)
-(UIImage*) setImageSize:(CGSize) size{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(UIImage*) cutImage:(CGRect) cutValue{
    if(![self isKindOfClass:[UIImage class]]){// like the java's instandOf
        return nil;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage],cutValue);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return  image;
}
-(UIImage*) cutImageFit:(CGSize) size{
    CGSize temp;
    if (self.size.width/size.width>self.size.height/size.height) {
        temp.height = self.size.height;
        temp.width = self.size.height/size.height*size.width;
    }else{
        temp.width = self.size.width;
        temp.height = self.size.width/size.width*size.height;
    }
    float x = (self.size.width-temp.width)/2;
    float y = (self.size.height-temp.height)/2;
    CGRect r = CGRectMake(x, y, temp.width, temp.height);
    return [self cutImage:r];
}
-(UIImage*) cutImageCenter:(CGSize) size{
    float x = (self.size.width-size.width)/2;
    float y = (self.size.height-size.height)/2;
    CGRect r = CGRectMake(x, y, size.width, size.height);
    return [self cutImage:r];
}
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//==>滤镜功能
+ (UIImage*)imageWithImage:(UIImage*)inImage colorMatrix:(int) colorMatrix
{
    
    
    NSArray *items = @[@"Original",
                   @"CILinearToSRGBToneCurve",
                   @"CIPhotoEffectChrome",
                   @"CIPhotoEffectFade",
                   @"CIPhotoEffectInstant",
                   @"CIPhotoEffectMono",
                   @"CIPhotoEffectNoir",
                   @"CIPhotoEffectProcess",
                   @"CIPhotoEffectTonal",
                   @"CIPhotoEffectTransfer",
                   @"CISRGBToneCurveToLinear",
                   @"CIVignetteEffect",
                   ];
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:inImage];
    
    CIFilter *filter = [CIFilter filterWithName:items[colorMatrix]
                                  keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    return image;
}

@end
