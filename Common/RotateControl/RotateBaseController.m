//
//  RotateBaseController.m
//  wxlearn
//
//  Created by rd on 14-8-1.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "RotateBaseController.h"
#import "Common.h"
@interface RotateBaseController (){
}
@property (nonatomic,readonly) int statusInit;
@end

@implementation RotateBaseController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [Common setNavigationBarHidden:YES];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _statusInit = 0;
    // Do any additional setup after loading the view.
}
-(void) viewWillAppear:(BOOL)animated{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        [Common setNavigationBarHidden:YES];
    }
    [UIViewController attemptRotationToDeviceOrientation];//这句是关键
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//    [self changeStatusBarHidden:YES];
}

-(CATransition*) cATransitionBeforeGoNext{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionMoveIn;//可更改为其他方式
    transition.subtype = kCATransitionFromRight;//可更改为其他方式
    return transition;
}

-(CATransition*) cATransitionBeforeBackPrevious{
    NSArray *vcs = ((UINavigationController*)([Common getWindow].rootViewController)).viewControllers;
    UIViewController *vc = [vcs count]>=2?[vcs objectAtIndex:[vcs count]-2]:nil;
    [self.navigationController.view.layer removeAnimationForKey:kCATransition];
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionReveal;//可更改为其他方式
    transition.subtype = kCATransitionFromLeft;//可更改为其他方式
    if (!vc) {
        return nil;
    }else{
        if(![vc isKindOfClass:[RotateBaseController class]]){
            if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
                SEL selector = NSSelectorFromString(@"setOrientation:");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:[UIDevice currentDevice]];
                int val = UIInterfaceOrientationPortrait;
                [invocation setArgument:&val atIndex:2];
                [invocation invoke];
            }
            [UIViewController attemptRotationToDeviceOrientation];//这句是关键
            transition.type = kCATransitionReveal;//可更改为其他方式
            transition.subtype = kCATransitionFromBottom;//可更改为其他方式
        }
    }
    return transition;
}

double timevlaue;
-(void) backPreviousControllerToSuper:(UIViewController *)superController{
    double curtimevalue = [[NSDate date] timeIntervalSince1970];
    if (curtimevalue-timevlaue<1) {
        return;
    }
    _statusInit = INT16_MAX;
    timevlaue =  curtimevalue;
    [super backPreviousControllerToSuper:superController];
//    [super backPreviousController];
}

-(BOOL)NCshouldAutorotate{
    switch (_statusInit) {
        case 0:{
            _statusInit++;
        }
            return YES;
        case 1:{
            _statusInit++;
        }
            return YES;
        case 2:{
            _statusInit++;
        }
            return YES;
        case INT16_MAX:{
        }
            return YES;
        default:{
            _statusInit++;
        }
            return NO;
    }
    return NO;
}

-(NSUInteger)NCsupportedInterfaceOrientations {
    switch (_statusInit) {
        case 0:{
        }
            return [super supportedInterfaceOrientations];
        case 1:{
        }
            return [super supportedInterfaceOrientations];
        case INT16_MAX:{
        }
            return [super supportedInterfaceOrientations];
        default:{
        }
            return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(void) NCdidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [Common setNavigationBarHidden:YES];
}
-(void) NCwillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}
- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}
//-(void) changeStatusBarHidden:(BOOL) flag{
//    self.statusBarHidden = flag;
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        // iOS 7
//        [self prefersStatusBarHidden];
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//    }
//}

-(void) dealloc{
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
