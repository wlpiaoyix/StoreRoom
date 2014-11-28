//
//  BaseController.m
//  super_gse
//
//  Created by wlpiaoyi on 14-7-15.
//  Copyright (c) 2014年 super_gse. All rights reserved.
//

#import "BaseController.h"
#import "Common.h"

@interface BaseController ()
@property int MyMBProgressHUDTAG;
@property (nonatomic,readonly) int statusInit;
@end

@implementation BaseController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    CGRect frame = CGRectMake(0, 0, APP_W, APP_H);
    self.view.frame = frame;
    [Common setNavigationBarHidden:NO];
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
}

/**
 设置显示键盘的动画
 */
-(void) setSELShowKeyBoardStart:(CallBackKeyboardStart) start End:(CallBackKeyboardEnd) end{
    self->showStart = start;
    self->showEnd = end;
}
/**
 设置隐藏键盘的动画
 */
-(void) setSELHiddenKeyBoardBefore:(CallBackKeyboardStart) start End:(CallBackKeyboardEnd) end{
    self->hiddenStart = start;
    self->hiddenEnd = end;
    [self setKeyboardNotification];
}

-(void)intputshow:(NSNotification *)notification{
    if(showStart){
        showStart();
    }
    if(showEnd){
        //键盘显示，设置toolbar的frame跟随键盘的frame
//        CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:0.25 animations:^{
            CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            keyBoardFrame.origin.y -= 20;
            showEnd(keyBoardFrame);
        }];
    }
    }

-(void)intputhidden:(NSNotification *)notification{
    if(hiddenStart){
        hiddenStart();
    }
    if(hiddenEnd){
        //键盘显示，设置toolbar的frame跟随键盘的frame
//        CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:0.25 animations:^{
            CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            hiddenEnd(keyBoardFrame);
        }];
    }
}
-(void) backPreviousController{
    [self backPreviousControllerToSuper:nil];
}
-(void) excuteBeforeBackPrevious{
}
-(CATransition*) cATransitionBeforeBackPrevious{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式式
    return transition;
}
-(void) backPreviousControllerToSuper:(UIViewController*) superController{
    [self excuteBeforeBackPrevious];
    [self.navigationController.view.layer removeAnimationForKey:kCAOnOrderIn];
    [self.navigationController.view.layer removeAnimationForKey:kCAOnOrderOut];
    [self.navigationController.view.layer addAnimation:[self cATransitionBeforeBackPrevious] forKey:kCAOnOrderOut];
    if (superController) {
        [self.navigationController popToViewController:superController animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(CATransition*) cATransitionBeforeGoNext{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式
    return transition;
}
-(void) goNextController:(UIViewController*) nextController{
    [self.navigationController.view.layer removeAnimationForKey:kCAOnOrderIn];
    [self.navigationController.view.layer removeAnimationForKey:kCAOnOrderOut];
    [self.navigationController.view.layer addAnimation:[self cATransitionBeforeGoNext] forKey:kCAOnOrderIn];
    [self.navigationController pushViewController:nextController animated:YES];
}

-(void)setKeyboardNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(intputshow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(intputhidden:) name:UIKeyboardWillHideNotification object:nil];
    _tapGestureRecognizer = [self.view addTarget:self action:@selector(resignFirstResponder)];
}

-(BOOL) NCshouldAutorotate {
    switch (_statusInit) {
        case 0:{
            _statusInit++;
        }
            return NO;
        case 1:{
            _statusInit++;
        }
            return NO;
        case 2:{
            _statusInit++;
        }
            return NO;
        case INT16_MAX:{
        }
            return NO;
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
            return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

-(void) NCdidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}
-(void) NCwillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}
-(BOOL) resignFirstResponder{
    return [super resignFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;//隐藏为YES，显示为NO
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
