//
//  myInfoViewController.m
//  daYiXin
//
//  Created by JGW on 15/6/12.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "myInfoViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"
#import "loginViewController.h"

#define ROW_USERINFO 0  //用户信息
#define ROW_USERNAME 0  //用户姓名
#define ROW_USERPHONE 1 //用户手机
#define ROW_USERADDRESS 2 //用户地址
#define ROW_DETAILEDADDRESS 3 //详细地址
#define ROW_MAINPRODUCT 4 //主营产品
#define ROW_EXIT 5//退出登录

@interface myInfoViewController ()<UITableViewDataSource,UITabBarDelegate,UITextFieldDelegate>
{
    
}

@end

@implementation myInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self viewWillAppear:YES];
    //设置表格视图不滚动
    myInfoTableView.scrollEnabled = NO;
    cellTitles = @[@"用户姓名:",@"用户手机:",@"用户地址:",@"详细地址:",@"主营产品:"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//视图将要出现方法
-(void)viewDidAppear:(BOOL)animated
{
    
    //如果导航栏按钮文本为编辑，所有的控件不可输入，只起到显示数据作用
    if ([_editOrSaveButtonItem.title isEqualToString:@"编辑"])
    {
        _changePwdButton.userInteractionEnabled = NO;
        _userNameText.enabled = NO;
        _userPhoneText.enabled = NO;
        _userAddressText.enabled = NO;
        _detailAddressText.enabled = NO;
        _mainProduct.enabled = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //调用获取用户信息接口
    userInfo = [_sharedClient getUserInfo];
    NSLog(@"用户资料信息%@", userInfo);
    
    _userName = userInfo[@"UserName"];//用户名
    _userPhone = userInfo[@"Mobile"]; //用户手机
    _userAddress = userInfo[@"Address"]; //用户地址
    _mainNote = userInfo[@"Note"]; //主营产品
    _loginName = userInfo[@"LoginName"]; //登录名

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return 6;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == ROW_USERINFO)
        {
            return 65;
        }
    }
    
    return 44;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //创建cell标识符
    static NSString * cellIdentifier1 = @"cellImageLabelButton";
    static NSString * cellIdentifier2 = @"cellLabelText";
    static NSString * cellIdentifier3 = @"cellButton";
    
    //自定义单元格
    UITableViewCell *cell;
    switch (indexPath.section)
    {
        case 0:
            //用户信息单元格
            if (indexPath.row == ROW_USERINFO)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
                _changePwdButton = UIButtonWithTag(11);
                _changePwdButton.layer.borderWidth = 1.0;
                _loginNameLabel = UILabelWithTag(10);
                
                if ([_editOrSaveButtonItem.title isEqualToString:@"编辑"])
                {
                    _loginNameLabel.text = _loginName;
                }
            }

            break;
        case 1:
            //用户姓名，手机，地址，详细地址，主营产品单元格
            if(indexPath.row == ROW_USERNAME || indexPath.row == ROW_USERPHONE ||indexPath.row == ROW_USERADDRESS || indexPath.row == ROW_DETAILEDADDRESS || indexPath.row == ROW_MAINPRODUCT)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
                
                //为单元格标签控件赋值
                UILabelWithTag(20).text = [cellTitles objectAtIndex: indexPath.row];
                //用户名
                if (indexPath.row == ROW_USERNAME)
                {
                    _userNameText = UITextFieldWithTag(21);
                    _userNameText.tag = 40;
                    
                    if ([_editOrSaveButtonItem.title isEqualToString:@"编辑"])
                    {
                        _userNameText.text = _userName;
                    }

                }
                //用户手机
                else if(indexPath.row == ROW_USERPHONE)
                {
                    _userPhoneText = UITextFieldWithTag(21);
                    _userPhoneText.tag = 41;
                    
                    if ([_editOrSaveButtonItem.title isEqualToString:@"编辑"])
                    {
                        _userPhoneText.text = _userPhone;
                    }

                }
                //用户地址
                else if(indexPath.row == ROW_USERADDRESS)
                {
                    _userAddressText = UITextFieldWithTag(21);
                    _userAddressText.tag = 42;
                    
                    if ([_editOrSaveButtonItem.title isEqualToString:@"编辑"])
                    {
                        _userAddressText.text = _userAddress;
                    }
                }
                //用户详细地址
                else if(indexPath.row == ROW_DETAILEDADDRESS)
                {
                    _detailAddressText = UITextFieldWithTag(21);
                    _detailAddressText.tag = 43;
                    
                }
                //主营产品
                else
                {
                    _mainProduct = UITextFieldWithTag(21);
                    _mainProduct.tag = 44;
                    
                    if ([_editOrSaveButtonItem.title isEqualToString:@"编辑"])
                    {
                        _mainProduct.text = _mainNote;
                    }
                }
            }
            //退出登录单元格
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
                _exitButton = UIButtonWithTag(30);
                //为退出的登录按钮添加点击事件
//                [_exitButton addTarget:self action:@selector(backLogin:) forControlEvents:UIControlEventTouchUpInside];
            }

            break;
            
        default:
            break;
    }
    return cell;
}

//实现退出登录按钮点击事件
//-(void)backLogin:(UIButton *)button
//{
//    
//}

//设置单元格修改或禁止选中
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_editOrSaveButtonItem.title isEqualToString:@"保存"])
    {
        if (indexPath.section == 1)
        {
            if (indexPath.row == ROW_USERADDRESS)
            {
                return indexPath;
            }
        }

    }
    return nil;
}

//导航栏编辑或保存按钮点击响应方法
- (IBAction)editOrSaveEventButtonItem:(UIBarButtonItem *)sender
{
    //如果导航栏按钮文本为保存，设置所有控件可交互
    [_editOrSaveButtonItem setTitle:@"保存"];
    if ([_editOrSaveButtonItem.title isEqualToString:@"保存"])
    {
        _changePwdButton.userInteractionEnabled = YES;
        _userNameText.enabled = YES;
        _userPhoneText.enabled = YES;
        _userAddressText.enabled = NO;
        _detailAddressText.enabled = YES;
        _mainProduct.enabled = YES;
        
        //判断旧密码是否输入
        if (_userNameText.text)
        {
            return;
        }

        if (_userPhoneText.text)
        {
            return;
        }

        if (_userAddressText.text)
        {
            return;
        }

        if (_mainProduct.text)
        {
            return;
        }

        //调用保存用户资料接口
        [_sharedClient editUserInfoWithUserName:_userName andMobile:_userPhone andAddress:_userAddress andNote:_mainNote];
        [myInfoTableView  reloadData]; 
        
        
    }
}

//对表格视图里行选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //***需要弹出城市选择器
    NSLog(@"用户地址\n");
}



@end
