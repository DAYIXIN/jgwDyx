//
//  newPwdViewController.h
//  daYiXin
//
//  Created by JGW on 15/6/14.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface newPwdViewController : BaseViewController


- (IBAction)backButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *myOldPwdText;
@property (weak, nonatomic) IBOutlet UITextField *myNewPwdText;
@property (weak, nonatomic) IBOutlet UITextField *checkNewPwdText;


@end
