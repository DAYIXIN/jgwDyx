//
//  XAddProBatchViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/22.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

//实现表格视图协议
@interface XAddProBatchViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UIBarButtonItem *saveButton;//保存按钮
    __weak IBOutlet UITableView *proBatchTableView; //表格视图
    
    NSArray *cellTitles; //单元格标题数组
    NSArray *cellKeys; //单元格数据key值数组
    NSArray *cellPlaceholders; //单元格占位符数组
    NSDictionary *proBatchDict;//用来保存服务器返回的数据
    NSMutableArray *addItemList;//用来存放新添加字段的可变数组
    NSDictionary *newAddedItemDict;//用来接收添加选项
    NSDictionary *batchInfo;//用来获取批次信息
    NSArray *contentString;//用来接收批次内容
    NSDictionary *contentDic;
    

    //BOOL editing;//状态
}

@property (weak, nonatomic)NSString *editingProID;//编辑中产品id
//@property (strong, nonatomic)UIView *datePickerView;//日期选择器视图
@property (weak, nonatomic) IBOutlet UIView *datePickerView;
//@property (strong, nonatomic)UIDatePicker *datePicker;//日期选择器
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
//@property (weak, nonatomic) IBOutlet UIView *unitView;
@property (weak, nonatomic) IBOutlet UIView *unitView;

@property (weak, nonatomic)UITextField *deliqutyAndTimeTextField;//供货量和生产日期共用文本框
@property (weak, nonatomic)UITextField *codeAndProducerTextField;//生产批次和生产人共用文本框
@property (weak, nonatomic)UITextField *productPriceTextField;//产品价格文本框

@property (weak, nonatomic)UITextField *deliqutyTextField;//供货量文本框
@property (weak, nonatomic)UITextField *codeTextField;//生产批次文本框
@property (weak, nonatomic)UITextField *producerTextField;//生产人文本框
@property (weak, nonatomic)UITextField *productionTimeTextField;//生产日期文本框
@property (weak, nonatomic)UIButton *unitButton;//单位按钮
@property (weak, nonatomic)NSString *unitButtonText;//单位按钮文本
@property (weak, nonatomic)NSString *btnText;//选择按钮文本

@property (weak, nonatomic)UIButton *btn;//循环创建8个按钮

//编辑批次用来存放文本输入框内容的字符串
@property (weak, nonatomic)NSString *code;//批次编码
@property (weak, nonatomic)NSString *content; //批次内容
@property (weak, nonatomic)NSString *deliquty;//供货量
@property (weak, nonatomic)NSString *unit;//单位
@property (weak, nonatomic)NSString *price;//价格
@property (weak, nonatomic)NSString *producer;//生产人
@property (weak, nonatomic)NSString *proTime;//生产日期
@property (weak, nonatomic)NSString *itemName;//添加项名
@property (weak, nonatomic)NSString *itemValue;//添加项值

//@property (weak, nonatomic) IBOutlet UIButton *cellButton;
//@property (weak, nonatomic)NSArray *btnTitle;
- (IBAction)finishedDateSelected:(UIBarButtonItem *)sender;
- (IBAction)saveData:(UIBarButtonItem *)sender;



@end
