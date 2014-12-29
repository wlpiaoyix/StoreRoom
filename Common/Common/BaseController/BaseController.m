//
//  BaseController.m
//  Common
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "BaseController.h"
#import "DeviceOrientationListener.h"
#import "SkinDictionary.h"
static UIDeviceOrientation STATIC_deviceOrientation;
static UIInterfaceOrientationMask STATIC_supportInterfaceOrientation;
@interface BaseController ()

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceOrientation = UIDeviceOrientationUnknown;
    if([systemVersion floatValue]>=7.0f){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated{
    if(self.navigationController.navigationBar.hidden==NO){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.580 blue:0.129 alpha:1];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        shadow.shadowOffset = CGSizeMake(0.5, 0.5);
        NSDictionary *navTitleArr = @{
                        NSFontAttributeName:[UIFont systemFontOfSize:20],
                        NSForegroundColorAttributeName:[UIColor whiteColor],
                        NSShadowAttributeName:shadow,
                        };
        [self.navigationController.navigationBar setTitleTextAttributes:navTitleArr];
    }
    [self.navigationController setNavigationBarHidden:NO];
    [Utils setStatusBarHidden:NO];
    if (self==[Utils getCurrentController]) {
        int val = _deviceOrientation;
        if (_toInterfaceOrientation!=UIInterfaceOrientationUnknown) {
            val = _toInterfaceOrientation;
        }
        STATIC_deviceOrientation = val;
        STATIC_supportInterfaceOrientation = _supportInterfaceOrientation;
        [DeviceOrientationListener attemptRotationToDeviceOrientation:val];
    }
}


-(void) setRightButtonName:(NSString*) name action:(SEL) action{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    NSDictionary *navTitleArr = @{
                    NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
                    NSForegroundColorAttributeName:[UIColor whiteColor],
                    NSShadowAttributeName:shadow,
                    };
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStyleDone target:self action:action];
    [rightBarButtonItem setTitleTextAttributes:navTitleArr forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
-(void) setLeftButtonName:(NSString*) name  action:(SEL) action{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    NSDictionary *navTitleArr = @{
                                  NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
                                  NSForegroundColorAttributeName:[UIColor whiteColor],
                                  NSShadowAttributeName:shadow,
                                  };
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStyleDone target:self action:action];
    [leftBarButtonItem setTitleTextAttributes:navTitleArr forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
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
    
    if (_tapGestureRecognizer&&showStart&&showEnd) {
        [self.view removeGestureRecognizer:_tapGestureRecognizer];
        [self.view addGestureRecognizer:_tapGestureRecognizer];
    }
    if(showStart){
        showStart();
    }
    if(showEnd){
        //键盘显示，设置toolbar的frame跟随键盘的frame
        CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:animationTime>0?animationTime:0.25 animations:^{
            CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            keyBoardFrame.origin.y -= 20;
            showEnd(keyBoardFrame);
        }];
    }
}

-(void)intputhidden:(NSNotification *)notification{
    if (_tapGestureRecognizer&&hiddenEnd&&hiddenStart) {
        [self.view removeGestureRecognizer:_tapGestureRecognizer];
    }
    if(hiddenStart){
        hiddenStart();
    }
    if(hiddenEnd){
        //键盘显示，设置toolbar的frame跟随键盘的frame
        CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:animationTime>0?animationTime:0.25 animations:^{
            CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            hiddenEnd(keyBoardFrame);
        }];
    }
}

//==>动画
-(CATransition*) backPerviousWithTransitionIn{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式式
    return transition;
}
-(CATransition*) backPerviousWithTransitionOut{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式式
    return transition;
}
-(CATransition*) goNextWithTransitionIn{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式式
    return transition;
}
-(CATransition*) goNextWithTransitionOut{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式式
    return transition;
}
//<==
-(void) backPreviousController{
    [self backPreviousControllerToSuper:nil];
}
-(void) backPreviousControllerToSuper:(UIViewController*) superController{
    if (superController) {
        [self checkAnimationWithOutController:self inController:superController falgIn:false];
    }
    if (superController) {
        [self.navigationController popToViewController:superController animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void) goNextController:(UIViewController*) nextController{
    [self checkAnimationWithOutController:self inController:nextController falgIn:true];
    
    if([self.navigationController.viewControllers count]>1){
        UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-1];
        [self checkAnimationWithOutController:self inController:vc falgIn:false];
    }
    
    [self.navigationController pushViewController:nextController animated:YES];
}

-(void)setKeyboardNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(intputshow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(intputhidden:) name:UIKeyboardWillHideNotification object:nil];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
}

-(void) checkAnimationWithOutController:(UIViewController*) outController inController:(UIViewController*) inController falgIn:(BOOL) flagIn{
    if (outController) {
        [outController.view.layer removeAnimationForKey:kCAOnOrderOut];
        [outController.view.layer addAnimation:flagIn?[self goNextWithTransitionOut]:[self backPerviousWithTransitionOut] forKey:kCAOnOrderOut];
    }
    if (inController) {
        [inController.view.layer removeAnimationForKey:kCAOnOrderIn];
        [inController.view.layer addAnimation:flagIn?[self goNextWithTransitionIn]:[self backPerviousWithTransitionIn] forKey:kCAOnOrderIn];
    }
}

//重写父类方法判断是否可以旋转
-(BOOL)shouldAutorotate{
    return YES;
}
//
////重写父类方法返回当前方向
-(NSUInteger) supportedInterfaceOrientations{
    return STATIC_supportInterfaceOrientation;
}



//重写父类方法判断支持的旋转方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return _toInterfaceOrientation;
}

//⇒ 重写父类方法旋转开始和结束
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval)duration{
    _toInterfaceOrientation = toInterfaceOrientation;
    [DeviceOrientationListener getSingleInstance].duration = duration;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation{
    _fromInterfaceOrientation = fromInterfaceOrientation;
}
//⇐


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    BOOL statusBarHidden = NO;
    [Utils setStatusBarHidden:statusBarHidden];
    return  statusBarHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
