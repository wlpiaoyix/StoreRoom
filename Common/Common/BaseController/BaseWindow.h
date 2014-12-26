//
//  BaseWindow.h
//  Common
//
//  Created by wlpiaoyi on 14/12/26.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "DeviceOrientationListener.h"
@interface BaseWindow : UIWindow<DeviceOrientationListenerDelegate>
@property (nonatomic) UIView *viewExternal;
@end
