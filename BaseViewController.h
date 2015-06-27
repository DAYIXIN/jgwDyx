//
//  BaseViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/21.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CommonObjects.h"

@interface BaseViewController : UIViewController
{
    MBProgressHUD * HUD;
}

//颜色选取器宏定义
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

-(void) showHUDWithMsg:(NSString *) msg;
-(void) hideHUD;
-(void) hideAnyKeyboard;

#define APP_H    [UIScreen mainScreen].bounds.size.height
#define APP_W    [UIScreen mainScreen].bounds.size.width
//各种宏定义
#define _commonObjects [CommonObjects sharedObjects]
#define CorpID _commonObjects.corpID
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
//消息通知中心实例的宏定义
#define DefaultNotificationCenter [NSNotificationCenter defaultCenter]
//通过tag值获取文本框
#define UITextFieldWithTag(TAG) ((UITextField *) [cell viewWithTag: TAG])
//通过tag值获取标签
#define UILabelWithTag(TAG) ((UILabel *) [cell viewWithTag: TAG])
//通过tag值获取按钮
#define UIButtonWithTag(TAG) ((UIButton *) [cell viewWithTag: TAG])
//通过tag值获取日期选择器视图
#define UIDatePickerViewWithTag(TAG) ((UIView *) [cell viewWithTag: TAG])
//通过tag值获取日期选择器
#define UIDatePickerWithTag(TAG) ((UIDatePicker *) [cell viewWithTag: TAG])
//通过tag值获取图片视图
#define UIImageViewWithTag(TAG) ((UIImageView *) [cell viewWithTag: TAG])
@end
