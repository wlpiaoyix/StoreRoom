//
//  ViewController.m
//  Common
//
//  Created by wlpiaoyi on 14/12/25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import "HViewController.h"

@interface ViewController ()
@property (nonatomic) UIButton *button;
@property (nonatomic) UIButton *buttonx;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _button = [UIButton new];
    _button.frame = CGRectMake(30, 60, 80, 80);
    [_button setTitle:@"SHU" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    [_button setBackgroundColor:[UIColor redColor]];
    [self setTitle:@"HENG"];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void) onclick{
    [self goNextController:[HViewController new]];
}
-(void) onclickx{
    [self backPreviousController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
