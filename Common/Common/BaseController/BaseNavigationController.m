//
//  BaseNavigationController.m
//  Common
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "BaseNavigationController.h"
#import "Utils.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
//重写父类方法判断是否可以旋转
-(BOOL)shouldAutorotate{
    UIViewController *vc = [Utils getCurrentController];
    if (vc) {
        return [vc shouldAutorotate];
    }
    return [super shouldAutorotate];
}

//重写父类方法返回当前方向
-(NSUInteger) supportedInterfaceOrientations{
    UIViewController *vc = [Utils getCurrentController];
    if (vc) {
        return [vc supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

//重写父类方法判断支持的旋转方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIViewController *vc = [Utils getCurrentController];
    if (vc) {
        return [vc preferredInterfaceOrientationForPresentation];
    }
    return [super preferredInterfaceOrientationForPresentation];
}

//⇒ 重写父类方法旋转开始和结束
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    UIViewController *vc = [Utils getCurrentController];
    if (vc) {
        return [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    return [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [Utils setStatusBarHidden:flagStatusBarHidden];
    UIViewController *vc = [Utils getCurrentController];
    if (vc) {
        return [vc didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    return [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
//⇐


- (UIStatusBarStyle)preferredStatusBarStyle{
    UIViewController *vc = [Utils getCurrentController];
    if (vc) {
        return [vc preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}
- (BOOL)prefersStatusBarHidden {
    UIViewController *vc = [Utils getCurrentController];
    BOOL flag;
    if (vc) {
        flag =  [vc prefersStatusBarHidden];
    }else{
        flag = [super prefersStatusBarHidden];
    }
    [Utils setStatusBarHidden:flag];
    return  flag;
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
