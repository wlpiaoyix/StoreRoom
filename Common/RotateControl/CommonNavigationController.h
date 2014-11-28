//
//  CommonPiaoyiViewController.h
//  wxlearn
//
//  Created by rd on 14-8-1.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProtocolNavigationController<NSObject>
@optional
-(BOOL) NCshouldAutorotate;
-(NSUInteger) NCsupportedInterfaceOrientations;
-(void) NCdidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void) NCwillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
@end
@interface CommonNavigationController : UINavigationController
@end
