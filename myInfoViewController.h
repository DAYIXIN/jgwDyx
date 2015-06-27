//
//  myInfoViewController.h
//  daYiXin
//
//  Created by JGW on 15/6/12.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface myInfoViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *cellTitles;
    __weak IBOutlet UITableView *myInfoTableView;
    NSDictionary *userInfo;//将通过接口获取到的用户资料存放在字典中
}

@property (weak, nonatomic)UIButton *exitButton;//退出登录按钮
@property (weak, nonatomic)UIButton *changePwdButton;//修改密码按钮
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editOrSaveButtonItem;
- (IBAction)editOrSaveEventButtonItem:(UIBarButtonItem *)sender;
@property (weak, nonatomic)UITextField *userNameText; //用户姓名
@property (weak, nonatomic)UITextField *userPhoneText; //用户手机
@property (weak, nonatomic)UITextField *userAddressText; //用户地址
@property (weak, nonatomic)UITextField *detailAddressText; //详细地址
@property (weak, nonatomic)UITextField *mainProduct; //主营产品
@property (weak, nonatomic)UILabel *loginNameLabel;//登录名

@property (weak, nonatomic)NSString *userName;
@property (weak, nonatomic)NSString *userPhone;
@property (weak, nonatomic)NSString *userAddress;
@property (weak, nonatomic)NSString *detailAddress;
@property (weak, nonatomic)NSString *mainNote;
@property (weak, nonatomic)NSString *loginName;



@end
