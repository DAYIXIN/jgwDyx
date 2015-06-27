//
//  historyMaViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/12.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface historyMaViewController : BaseViewController
{
    
    __weak IBOutlet UITableView *historyMaTableView;
    NSMutableArray *insertCellArray;//插入行数组
    
    __weak IBOutlet UIView *datePickerView;//日期选择器视图
    
    __weak IBOutlet UIDatePicker *datePicker;//日期选择器
    
}

@property (weak, nonatomic)UILabel *MaLabel;
@property (weak, nonatomic)UILabel *batchNameLabel;
@property (weak, nonatomic)UILabel *proNameLabel;
@property (weak, nonatomic)UIButton *choseDateOneButton;//选择日期第一个按钮
@property (weak, nonatomic)UIButton *choseDateTwoButton;//选择日期第二个按钮
@property (weak, nonatomic)UIButton *checkButton;//扫码历史查询按钮
@property (weak, nonatomic)NSString *flag;

@property (weak, nonatomic)UITextField *proBatchText;


- (IBAction)finishedDateSelected:(UIBarButtonItem *)sender;




@end
