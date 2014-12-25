//
//  HorizontalController.m
//  Common
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "HorizontalController.h"

@interface HorizontalController ()

@end

@implementation HorizontalController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
    self.supportInterfaceOrientation = UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    // Do any additional setup after loading the view.
}



- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    BOOL flag = NO;
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
