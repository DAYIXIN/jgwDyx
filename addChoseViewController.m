//
//  addChoseViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/13.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "addChoseViewController.h"

@interface addChoseViewController ()

@end

@implementation addChoseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //点击手势识别器，隐藏键盘的方法
    [self hideAnyKeyboard];
}

//隐藏键盘的方法
-(void)hidenKeyboard:(UITextField *)textfield
{
    //让文本框失去第一响应者
    [_ItemName resignFirstResponder];
    [_ItemValue resignFirstResponder];
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

//视图将要出现方法,不隐藏导航栏
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

//完成按钮点击事件
//功能：如果用户有输入，就将用户输入数据传递给界面2第二分区进行显示，如果用户没有输入，就返回nil
- (IBAction)finishedAddButton:(UIButton *)sender
{
    //如果输入框文本不为空
    if (_ItemName.text.length > 0 && _ItemValue.text.length > 0)
    {
        NSLog(@"%@\n",_ItemName.text);
        //todo 初始化 要的
        CustomItems = [NSMutableDictionary dictionary];
        //把文本根据key放入可变数组中
        [CustomItems setObject:_ItemName.text forKey:@"ItemName"];
        [CustomItems setObject:_ItemValue.text forKey:@"ItemValue"];
        //如果用户有输入，就发送一个值变更消息
        [DefaultNotificationCenter postNotificationName:@"newChose" object:CustomItems];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    
}
@end
