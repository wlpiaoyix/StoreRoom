//
//  UIView+convenience.m
//
//  Created by Tjeerd in 't Veen on 12/1/11.
//  Copyright (c) 2011 Vurig Media. All rights reserved.
//

#import "UIView+Expand.h"
#import "MBProgressHUD.h"
@interface UIView(){
}
@end
@implementation UIView (Expand)

-(CGPoint) getAbsoluteOrigin:(UIView*) superView{
    CGPoint origin = CGPointMake(0, 0);
    UIView *sv = self;
    while (sv) {
        CGPoint p = sv.frame.origin;
        origin.x += p.x;
        origin.y += p.y;
        sv = sv.superview;
        if (sv==superView) {
            sv = nil;
            break;
        }
    }
    return origin;
}
-(BOOL) containsSubView:(UIView *)subView
{
    for (UIView *view in [self subviews]) {
        if ([view isEqual:subView]) {
            return YES;
        }
    }
    return NO;
}

 
-(BOOL) containsSubViewOfClassType:(Class)clazz {
    for (UIView *view in [self subviews]) {
        if ([view isMemberOfClass:clazz]) {
            return YES;
        }
    }
    return NO;
}

-(UITapGestureRecognizer*) addTarget:(id)target action:(SEL)action{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [self addGestureRecognizer:tapGesture];
    return tapGesture;
}

-(void)setCornerRadiusAndBorder:(CGFloat)radius BorderWidth:(CGFloat)width BorderColor:(UIColor *)color{
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = width;
    if(color)self.layer.borderColor = color.CGColor;
    [self setClipsToBounds:YES];
}

- (CGPoint)frameOrigin {
	return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)newOrigin {
	self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)frameSize {
	return self.frame.size;
}

- (void)setFrameSize:(CGSize)newSize {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							newSize.width, newSize.height);
}

- (CGFloat)frameX {
	return self.frame.origin.x;
}

- (void)setFrameX:(CGFloat)newX {
	self.frame = CGRectMake(newX, self.frame.origin.y,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameY {
	return self.frame.origin.y;
}

- (void)setFrameY:(CGFloat)newY {
	self.frame = CGRectMake(self.frame.origin.x, newY,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameRight {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setFrameRight:(CGFloat)newRight {
	self.frame = CGRectMake(newRight - self.frame.size.width, self.frame.origin.y,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameBottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setFrameBottom:(CGFloat)newBottom {
	self.frame = CGRectMake(self.frame.origin.x, newBottom - self.frame.size.height,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameWidth {
	return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)newWidth {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							newWidth, self.frame.size.height);
}

- (CGFloat)frameHeight {
	return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)newHeight {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							self.frame.size.width, newHeight);
}
-(UIImage*) drawView{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(void) autoresizingMask_TB{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
}
-(void) autoresizingMask_TLR{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}
-(void) autoresizingMask_TBLRH{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}
-(void) autoresizingMask_BW{
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
}
-(void) autoresizingMask_BLR{
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}
-(void) autoresizingMask_TLRW{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
}
-(void) autoresizingMask_TBLRWH{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}
-(void) autoresizingMask_TBRWH{
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}
-(void) autoresizingMask_TBH{
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
}
-(void) autoresizingMask_TBL{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
}
-(void) autoresizingMask_TBLH{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
}
-(void) autoresizingMask_TBRH{
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
}
-(void) autoresizingMask_TBR{
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
}
-(void) autoresizingMask_LB{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
}
-(void) autoresizingMask_LR{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}
-(void) autoresizingMask_BLRW{
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
}

@end
