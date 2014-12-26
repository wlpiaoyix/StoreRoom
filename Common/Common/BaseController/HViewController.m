//
//  HViewController.m
//  Common
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "HViewController.h"
#import "ViewController.h"

@interface HViewController ()
@property (nonatomic) UIButton *button;
@property (nonatomic) UIButton *buttonx;

@end

@implementation HViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _button = [UIButton new];
    _button.frame = CGRectMake(30, 60, 80, 80);
    [_button setTitle:@"HENG" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    [_button setBackgroundColor:[UIColor redColor]];
    [self setTitle:@"SHU"];
    
    
    
    
    _buttonx = [UIButton new];
    _buttonx.frame = CGRectMake(30, 140, 80, 80);
    [_buttonx setTitle:@"afasdf" forState:UIControlStateNormal];
    [_buttonx addTarget:self action:@selector(onclickx) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonx];
    [_buttonx setBackgroundColor:[UIColor redColor]];
    
    // Do any additional setup after loading the view.
}
-(void) onclick{
    [self goNextController:[ViewController new]];
}
-(void) onclickx{
    [Utils showAlert:@"我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀我少我杀" Title:nil];
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
