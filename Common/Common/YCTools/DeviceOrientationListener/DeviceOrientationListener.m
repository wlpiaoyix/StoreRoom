//
//  DeviceOrientationListener.m
//  Common
//
//  Created by wlpiaoyi on 14/12/26.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "DeviceOrientationListener.h"
#import "Utils.h"

static DeviceOrientationListener *xDeviceOrientationListener;
static id synDeviceOrientationListener;

@interface DeviceOrientationListener()
@property (strong,nonatomic) NSMutableArray *arrayListeners;
@end

@implementation DeviceOrientationListener
+(void) initialize{
    synDeviceOrientationListener = [NSObject new];
}
-(id) init{
    if(self=[super init]){
        UIDevice *device = [UIDevice currentDevice]; //Get the device object
        [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
        
        self.soundPath = [[NSBundle mainBundle] pathForResource:@"device_orientation"
                                                              ofType:@"wav"];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
        [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
        self.arrayListeners = [NSMutableArray new];
    }
    return self;
}

+(DeviceOrientationListener*) getSingleInstance{
    @synchronized(synDeviceOrientationListener){
        if (!xDeviceOrientationListener) {
            xDeviceOrientationListener = [DeviceOrientationListener new];
            xDeviceOrientationListener.duration = GALOB_ANIMATION_TIME;
        }
    }
    return xDeviceOrientationListener;
}

/**
 旋转当前装置
 */
+(void) attemptRotationToDeviceOrientation:(UIDeviceOrientation) deviceOrientation{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        [[self getSingleInstance] setOrientation:deviceOrientation];
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = deviceOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        [UIViewController attemptRotationToDeviceOrientation];//这句是关键
    }
}

-(void) addListener:(id<DeviceOrientationListenerDelegate>) listener{
    @synchronized(self.arrayListeners){
        if ([self.arrayListeners containsObject:self]) {
            return;
        }
        [self.arrayListeners addObject:listener];
    }
}
-(void) removeListenser:(id<DeviceOrientationListenerDelegate>) listener{
    @synchronized(self.arrayListeners){
        [self.arrayListeners removeObject:listener];
    }
}

- (void)orientationChanged:(NSNotification *)note{
    @synchronized(self.arrayListeners){
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        UIInterfaceOrientationMask  supportedOrientations= [[Utils getWindow].rootViewController supportedInterfaceOrientations];
        int all = supportedOrientations;
        int cur = 1<<orientation;
        if (!(all&cur)) {
            return;
        }
        supportedOrientations = [[Utils getCurrentController] supportedInterfaceOrientations];
        all = supportedOrientations;
        if (!(all&cur)) {
            return;
        }
        [self setOrientation:orientation];
        for (id<DeviceOrientationListenerDelegate> listener in self.arrayListeners) {
            switch (_orientation) {
                    // Device oriented vertically, home button on the bottom
                case UIDeviceOrientationPortrait:{
                    [listener deviceOrientationPortrait];
                }
                    break;
                    // Device oriented vertically, home button on the top
                case UIDeviceOrientationPortraitUpsideDown:{
                    [listener deviceOrientationPortraitUpsideDown];
                }
                    break;
                    // Device oriented horizontally, home button on the right
                case UIDeviceOrientationLandscapeLeft:{
                    [listener deviceOrientationLandscapeLeft];
                }
                    break;
                    // Device oriented horizontally, home button on the left
                case UIDeviceOrientationLandscapeRight:{
                    [listener deviceOrientationLandscapeRight];
                }
                    break;
                default:{
                }
                    break;
            }
        }
    }
}

-(void) setOrientation:(UIDeviceOrientation)orientation{
    if (_orientation!=orientation) {
        [Utils soundWithPath:self.soundPath isShake:YES];
    }
    _orientation = orientation;
}

-(void) dealloc{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device endGeneratingDeviceOrientationNotifications]; //Tell it to end monitoring the accelerometer for orientation
    [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

@end
