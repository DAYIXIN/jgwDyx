//
//  newPwdViewController.m
//  daYiXin
//
//  Created by JGW on 15/6/14.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "newPwdViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"

@interface newPwdViewController ()

@end

@implementation newPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置密码输入框密文输入
    _myOldPwdText.secureTextEntry = YES;
    _myNewPwdText.secureTextEntry = YES;
    _checkNewPwdText.secureTextEntry = YES;
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

- (IBAction)backButton:(UIButton *)sender
{
    //判断旧密码是否输入
    if ([_myOldPwdText.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入原密码" : nil];
        return;
    }
    //判断新密码是否输入
    if ([_myNewPwdText.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入新密码" : nil];
        return;
    }
    //判断旧密码是否输入
    if ([_checkNewPwdText.text length]<1)
    {
        [_commonUtils showMessageBox: @"请确认新密码" : nil];
        return;
    }
    
    if ([_myNewPwdText.text isEqualToString:_checkNewPwdText.text] )
    {
        //调用修改密码接口
        [_sharedClient changePasswordWithOldPwd:_myOldPwdText.text andNewPwd:_myNewPwdText.text];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self showHUDWithMsg: @"请确认新密码是否一致!"];
        [self hideHUD];
    }
}
@end
