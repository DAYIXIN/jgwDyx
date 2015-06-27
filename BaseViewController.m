//
//  BaseViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/21.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
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

-(void) showHUDWithMsg:(NSString *) msg
{
    UIView * view = self.navigationController.view;
    if (view==nil)
        view = self.view;
    HUD = [[MBProgressHUD alloc] initWithView: view];
    [view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = msg;
    HUD.margin = 20.0;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD show: YES];
    
    NSDate * beginDate = [NSDate date];
    NSDate * timeOutDate = [NSDate dateWithTimeInterval: 0.01 sinceDate: beginDate];
    [[NSRunLoop mainRunLoop] runUntilDate: timeOutDate];
    //    [_commonUtils mySleep: 0.01];
}

-(void) hideHUD
{
    [HUD hide: YES];
}

//视图将要出现方法,不隐藏导航栏
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

//创建手势识别器，实现隐藏键盘方法
-(void)hideAnyKeyboard
{
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard:)];
    //设置点击次数和点击手指数
    tapGesture.numberOfTapsRequired = 1; //点击次数
    tapGesture.numberOfTouchesRequired = 1; //点击手指数
    [self.view addGestureRecognizer:tapGesture];

}

@end
