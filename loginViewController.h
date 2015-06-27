//
//  loginViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/7.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "baseMeansViewController.h"

@interface loginViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
- (IBAction)loginButtonClicker:(id)sender;

@property (weak, nonatomic)NSString *orgID;//用来存放机构id
@property (weak, nonatomic)baseMeansViewController *delegate;//定义基地信息类为自己的代理对象

@end
