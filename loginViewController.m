//
//  loginViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/7.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "loginViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"

//rgb宏定义
//#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface loginViewController ()<UITextFieldDelegate>

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    //设置导航栏背景色
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.barTintColor  = UIColorFromRGB(0xD3600E);
//     //设置导航栏标题文本属性为白色
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    //设置导航栏不透明
//    self.navigationController.navigationBar.translucent = NO;
    
    //设置密码框密文输入
    self.pwdTextField.secureTextEntry = YES;
    //保留用户登录的token，下次登录直接输入密码即可
    self.userTextField.text = [USER_DEFAULT objectForKey:@"lastUser"];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard:)];
    //设置点击次数和点击手指数
    tapGesture.numberOfTapsRequired = 1; //点击次数
    tapGesture.numberOfTouchesRequired = 1; //点击手指数
    [self.view addGestureRecognizer:tapGesture];
    
    self.pwdTextField.delegate=self;
    self.userTextField.delegate=self;
    
   }

//TextFeild代理方法，文本框开始编辑
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.0 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, -216, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

//隐藏键盘的方法
-(void)hidenKeyboard:(UITextField *)textfield
{
    //让文本框失去第一响应者
    [_userTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [UIView animateWithDuration:0.0 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//视图将要出现方法，设置导航栏隐藏
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - control actions
- (IBAction)loginButtonClicker:(id)sender
{
    [self.view endEditing:YES];
    //判断用户名是否输入
    if ([self.userTextField.text length]<3)
    {
        [_commonUtils showMessageBox: @"请输入用户名" : nil];
        return;
    }
    
    //判断密码是否输入
    if ([self.pwdTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入密码" : nil];
        return;
    }

    //因为登陆是同步调用，所以在界面上有一个等待的图标提示
    [self showHUDWithMsg: @"登录中"];

    //这里是调用登陆接口，并且把登陆后得到的数据，存放在userDict这个字典里
    NSDictionary * userDict = [_sharedClient loginWithUser: self.userTextField.text andPassword: self.pwdTextField.text];
    _orgID = userDict[@"OrgID"];
    NSLog(@"登录接口返回的数据%@", userDict);
    //把密码输入框清空
    self.pwdTextField.text = nil;
    
    [self hideHUD];
    
    if (userDict) //登录成功
    {
        //如果登陆成功，就弹出首页界面
        [self performSegueWithIdentifier: @"segueHomePage" sender: sender];
       
        //保存token,调用其它接口时，不再提交用户名和密码，而是提交代表用户身份的token
        TOKEN = [userDict objectForKey: @"Token"];        
        
        if ([CorpID intValue]!=[[userDict objectForKeyedSubscript: @"CorpID"] intValue])
            //RUNITE_DICT是一个NSMutableDictionary，用来保存app在运行时的一些临时数据
            RUNTIME_DICT = [[NSMutableDictionary alloc] init];
        //保存CorpID
        CorpID = [NSString stringWithFormat: @"%d", [[userDict objectForKeyedSubscript: @"CorpID"] intValue]];
        //保存PowerCode（该用户拥有的权限代码）
        PowerCode = [userDict objectForKey: @"PowerCode"];
        
        //保存上一次登录的用户名，在app退出登录后，用户不需要输入用户名，只需要输入密码即可
        [USER_DEFAULT setObject: self.userTextField.text forKey: @"lastUser"];
    }
    else
    {
        [_commonUtils showMessageBox: @"登录失败" : _sharedClient.errorMessage];
        //如果登陆失败，就禁止弹出首页界面
        [self shouldPerformSegueWithIdentifier:@"segueHomePage" sender:sender];
        
    }
    

}

//如果登陆不成功，就禁止跳到首页界面
-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"segueHomePage"])
    {
        return  NO;
    }
    return YES;
}
@end
