//
//  UIImage+Convenience.h
//  AKSL-189-Msp
//
//  Created by AKSL-td on 13-12-3.
//  Copyright (c) 2013年 AKSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Convenience)
-(UIImage*) setImageSize:(CGSize) size;
-(UIImage*) cutImage:(CGRect) cutValue;
-(UIImage*) cutImageCenter:(CGSize) size;
-(UIImage*) cutImageFit:(CGSize) size;
+(UIImage*) imageWithColor:(UIColor *)color;
/*滤镜功能*/
+(UIImage*) imageWithImage:(UIImage*)inImage colorMatrix:(int) colorMatrix;
@end
