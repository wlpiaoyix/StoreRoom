//
//  CommonPiaoyiViewController.m
//  wxlearn
//
//  Created by rd on 14-8-1.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "CommonNavigationController.h"
#import "ReflectClass.h"



@interface CommonNavigationController ()
@end

@implementation CommonNavigationController

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
    // Do any additional setup after loading the view.
}

-(BOOL)shouldAutorotate {
    bool resultValue = [super shouldAutorotate];
    UIViewController *vc = self.viewControllers.lastObject;
//    SEL selector = [ReflectClass getSEL:@"NCshouldAutorotate" Target:vc];
    Method origMethod = class_getInstanceMethod(vc.class, @selector(NCshouldAutorotate));
    if (origMethod) {
        resultValue = [((id<ProtocolNavigationController>)vc) NCshouldAutorotate];
    }else{
        resultValue = [vc shouldAutorotate];
    }
    return resultValue;
}

-(NSUInteger)supportedInterfaceOrientations {
    NSUInteger resultValue = [super supportedInterfaceOrientations];
    UIViewController *vc = self.viewControllers.lastObject;
    Method origMethod = class_getInstanceMethod(vc.class, @selector(NCsupportedInterfaceOrientations));
    if (origMethod) {
        resultValue = [((id<ProtocolNavigationController>)vc) NCsupportedInterfaceOrientations];
    }else{
        resultValue = [vc supportedInterfaceOrientations];
    }
    return resultValue;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return [super preferredInterfaceOrientationForPresentation];
//}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UIViewController *vc = self.viewControllers.lastObject;
//    SEL selector = [ReflectClass getSEL:@"NCdidRotateFromInterfaceOrientation:" Target:vc];
    Method origMethod = class_getInstanceMethod(vc.class, @selector(NCdidRotateFromInterfaceOrientation:));
    if (origMethod) {
        [((id<ProtocolNavigationController>)vc) NCdidRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }else{
        [vc didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    UIViewController *vc = self.viewControllers.lastObject;
    Method origMethod = class_getInstanceMethod(vc.class, @selector(NCwillRotateToInterfaceOrientation:duration:));
    if (origMethod) {
        [((id<ProtocolNavigationController>)vc) NCwillRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }else{
        [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    return ;
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
