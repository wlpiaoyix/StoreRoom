//
//  SimpleGraphicsContext.m
//  Common
//
//  Created by wlpiaoyi on 14-9-29.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "GraphicsContext.h"
#import "Common.h"
#import <CoreText/CoreText.h>
static NSLock *lockdrawImage;
@implementation GraphicsContext{

}
+(void) initialize{
    lockdrawImage = [NSLock new];
}
+(void) drawLineDash:(CGContextRef)ctx StartPoint:(CGPoint) startPoint EndPoint:(CGPoint) endPoint LineColor:(CGColorRef) lineColor LineWidth:(int) lineWidth  Lengths:(const CGFloat[]) lengths Count:(size_t) count {
    BOOL flagcgtx = true;
    if (!ctx) {
        flagcgtx = false;
        ctx = UIGraphicsGetCurrentContext();
    }
    //线宽设定
    CGContextSetLineWidth(ctx, lineWidth);
    //线的边角样式（圆角型）
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    //（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
    CGContextSetLineDash(ctx, 0, lengths, count);
    //如果要恢复线的属性只需要输入null即可
//    CGContextSetLineDash(ref, 0, NULL, 0);
    //线条颜色
    CGContextSetStrokeColorWithColor(ctx, lineColor);
    
    //移动绘图点
    CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
    //绘制直线
    CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
    if (!flagcgtx) {
        //开始绘制线并在view上显示
        CGContextStrokePath(ctx);
    }
}
+(void) drawPolygon:(CGContextRef) context Points:(const CGPoint[]) points PointsLength:(int) pointsLength FillColor:(CGColorRef) fillColor StrokeColor:(CGColorRef) strokeColor LineWidth:(int) lineWidth{
    BOOL flagcgtx = true;
    if (!context) {
        flagcgtx = false;
        context = UIGraphicsGetCurrentContext();
    }
    //线宽设定
    CGContextSetLineWidth(context, lineWidth);
    //线的边角样式（圆角型）
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    //（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextBeginPath(context);
    //移动绘图点
    CGContextMoveToPoint(context, points[0].x, points[0].y);
    for (int i=1; i<pointsLength; i++) {
        //绘制直线
        CGContextAddLineToPoint(context, points[i].x, points[i].y);
    }
    //封闭
    CGContextClosePath(context);
    if (strokeColor){
        //线条颜色
        CGContextSetStrokeColorWithColor(context, strokeColor);
    }
    if (fillColor) {
        //填充颜色
        CGContextSetFillColorWithColor(context, fillColor);
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    }
    if (!flagcgtx) {
        //开始绘制线并在view上显示
        CGContextStrokePath(context);
    }
}
+(void) drawRectangle:(CGContextRef) context Point:(CGPoint) point FillColor:(CGColorRef) fillColor StrokeColor:(CGColorRef) strokeColor LineWidth:(int) lineWidth Width:(CGFloat) width Height:(CGFloat) height{
    CGPoint pointru = CGPointMake(point.x+width, point.y);
    CGPoint pointrd = CGPointMake(point.x+width, point.y+height);
    CGPoint pointld = CGPointMake(point.x, point.y+height);
    const CGPoint points[] = {point,pointru,pointrd,pointld};
    const int pointsLength = 4;
    [self drawPolygon:context Points:points PointsLength:pointsLength FillColor:fillColor StrokeColor:strokeColor LineWidth:lineWidth];
}
+(void) drawCircle:(CGContextRef) context  Point:(CGPoint) point FillColor:(CGColorRef) fillColor StrokeColor:(CGColorRef) strokeColor LineWidth:(CGFloat) lineWidth StartDegrees:(int) startDegrees EndDegrees:(int) endDegrees Radius:(int) radius{
    BOOL flagcgtx = true;
    if (!context) {
        flagcgtx = false;
        context = UIGraphicsGetCurrentContext();
    }
    //（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineCap(context, kCGLineCapRound);//线的边角样式（圆角型）
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, lineWidth);//线的宽度
    
    if (strokeColor) {
        CGContextSetStrokeColorWithColor(context, strokeColor); //线条颜色
        CGContextAddArc(context, point.x+radius, point.y+radius, radius, [Common parseDegreesToRadians:startDegrees], [Common parseDegreesToRadians:endDegrees], 0); //添加一个圆
    }
    if (fillColor) {
        CGContextSetFillColorWithColor(context, fillColor);//填充颜色
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    }
    
    if (!flagcgtx) {
        //开始绘制线并在view上显示
        CGContextStrokePath(context);
    }
}
+(void) drawEllipse:(CGContextRef) context Rect:(CGRect) rect FillColor:(CGColorRef) fillColor StrokeColor:(CGColorRef) strokeColor LineWidth:(CGFloat) lineWidth{
    BOOL flagcgtx = true;
    if (!context) {
        flagcgtx = false;
        context = UIGraphicsGetCurrentContext();
    }
    //（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineCap(context, kCGLineCapRound);//线的边角样式（圆角型）
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, lineWidth);//线的宽度
    
    if (fillColor) {
        CGContextSetFillColorWithColor(context, fillColor);//填充颜色
        CGContextFillEllipseInRect(context,rect);//添加一个圆
    }
    if (strokeColor) {
        CGContextSetStrokeColorWithColor(context, strokeColor); //线条颜色
        CGContextStrokeEllipseInRect(context, rect);//添加一个圆
    }
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    
    if (!flagcgtx) {
        //开始绘制线并在view上显示
        CGContextStrokePath(context);
    }
}
+(void) drawText:(CGContextRef) context Text:(NSString*) text Font:(UIFont*) textFont Point:(CGPoint) textPoint TextColor:(UIColor*) textColor{
    if (text!=nil&&text.length) {
        CGSize size = CGSizeMake(9999, textFont.pointSize);
        size = [Common getBoundingRectWithSize:text font:textFont size:size];
        if (!context) {
            NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
            [ps setAlignment:NSTextAlignmentCenter];
            [ps setLineBreakMode:NSLineBreakByClipping];
            [text drawInRect:CGRectMake(textPoint.x, textPoint.y, size.width, size.height)  withAttributes:@{NSFontAttributeName:textFont,NSParagraphStyleAttributeName:ps,NSForegroundColorAttributeName:textColor}];
        }else{
            CGFloat fontSize = textFont.pointSize;
            CTFontRef fontRef = CTFontCreateWithName(((CFStringRef)textFont.fontName), fontSize, NULL);
            
            // Create an attributed string
            CFStringRef keys[] = { kCTFontAttributeName,kCTForegroundColorAttributeName };
            CFTypeRef values[] = { fontRef,[textColor CGColor]};
            CFDictionaryRef attributes = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFStringRef strRef = CFStringCreateWithCString(nil, [text UTF8String], kCFStringEncodingUTF8);
            
            CFAttributedStringRef attrString = CFAttributedStringCreate(NULL,strRef, attributes);
            CTLineRef line = CTLineCreateWithAttributedString(attrString);
//            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//            CGContextSetTextMatrix(context, CGAffineTransformMakeRotation(3.14));
            CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
            CGContextSetTextPosition(context, textPoint.x, textPoint.y+fontSize);
            CTLineDraw(line, context);
            
            // Clean up
            CFRelease(attributes);
            CFRelease(line);
            CFRelease(attrString);
            CFRelease(strRef);
            CFRelease(fontRef);
            
        }
    }
}
+(void) drawColors:(CGContextRef) context location:(CGRect) location startColor:(UIColor*) startColor endColor:(UIColor*) endColor{
    // 绘制颜色渐变
    BOOL flagcgtx = true;
    if (!context) {
        flagcgtx = false;
        context = UIGraphicsGetCurrentContext();
    }
//    CGContextClearRect(context, CGRectMake(0, 0, 320, 60));
    
    //线的边角样式（圆角型）
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    
    //绘制一个垂线，让它的轮廓形状成为裁剪区域
    CGContextMoveToPoint(context, location.origin.x, location.origin.y);
    CGContextAddLineToPoint(context, location.origin.x, location.origin.y+location.size.height);
    CGContextSetLineWidth(context, location.size.width*2);
    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);
    
    // 创建色彩空间对象
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    // 创建起点颜色
    CGColorRef beginColorRef = [startColor CGColor];
    // 创建终点颜色
    CGColorRef endColorRef = [endColor CGColor];
    // 创建颜色数组
    CFArrayRef colorArray = CFArrayCreate(kCFAllocatorDefault, (const void*[]){beginColorRef, endColorRef}, 2, nil);
    // 创建渐变对象
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpaceRef, colorArray, (CGFloat[]){
        0.0f,	   // 对应起点颜色位置
        1.0f		// 对应终点颜色位置
    });
    // 释放颜色数组
    CFRelease(colorArray);
    // 释放起点和终点颜色
    CGColorRelease(beginColorRef);
    CGColorRelease(endColorRef);
    // 释放色彩空间
    CGColorSpaceRelease(colorSpaceRef);
    CGContextDrawLinearGradient(context, gradientRef, location.origin, CGPointMake(location.origin.x+location.size.width, location.origin.y), 0);
    // 释放渐变对象
    CGGradientRelease(gradientRef);
    //完成裁剪
//    CGContextRestoreGState(context);
    if (!flagcgtx) {
        //开始绘制线并在view上显示
        CGContextStrokePath(context);
    }
}
+(CGContextRef) drawImageStart:(CGRect) rect fillColor:(CGColorRef) fillcolor{
    [lockdrawImage lock];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fillcolor);
    CGContextFillRect(context, rect);
    return context;
}
+(UIImage*) drawImgeEnd:(CGContextRef) context{
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [lockdrawImage unlock];
    return image;
}
@end
