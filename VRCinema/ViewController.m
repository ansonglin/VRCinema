//
//  ViewController.m
//  VRCinema
//
//  Created by asl on 2017/2/23.
//  Copyright © 2017年 Invisionhealth Digital Inc. All rights reserved.
//

#import "ViewController.h"
#import "VRCinemaViewController.h"
#import "VRMovieViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createButtonWithTitle:@"影院模式" frameCenter:CGPointMake(self.view.center.x, self.view.center.y - 80) tag:10];
    [self createButtonWithTitle:@"VR模式" frameCenter:CGPointMake(self.view.center.x, self.view.center.y + 80) tag:20];
}

- (void)createButtonWithTitle:(NSString *)title frameCenter:(CGPoint)center tag:(NSInteger)tag
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    button.center = center;
    button.tag = tag;
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 10;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 10:
        {
#warning mark
#warning mark -- 在这里取到视频文件
            NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
            VRCinemaViewController *viewController = [[VRCinemaViewController alloc] initWithUrl:[NSURL fileURLWithPath:path]];
//            [viewController prefersStatusBarHidden];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 20:
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
            VRMovieViewController *viewController = [[VRMovieViewController alloc] initWithUrl:[NSURL fileURLWithPath:path]];
//            [viewController prefersStatusBarHidden];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
