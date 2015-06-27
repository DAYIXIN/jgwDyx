//
//  XAddProBatchViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/22.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "XAddProBatchViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"
#import "SBJson.h"


//宏定义，代表单元格项的索引值
//0,3 共用一个单元格
//1,4 共用一个单元格
//2 单独一个单元格
#define ROW_CODE 0  //批次编码
#define ROW_DELIQUTY 1 //供货量
#define ROW_PRODUCTPRICE 2 //产品价格
#define ROW_PRODUCER 3 //生产人
#define ROW_PRODUCTIONTIME 4 //生产日期

//实现表格视图的三个协议
@interface XAddProBatchViewController ()
@property (nonatomic, strong) NSDictionary *sourceDic;
//@property (nonatomic, weak)NSDictionary *contentDic;
@end

@implementation XAddProBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //调用基类方法，视图将要出现时，设置导航栏不隐藏
    [self viewWillAppear:YES];
    
    //准备数据,单元格标签title
    cellTitles = @[@"批次编码:", @"供货量:", @"产品价格:", @"生产人:",@"生产日期:"];
    cellKeys = @[@"BatchCode",@"Deliquty",@"ProductPrice",@"Producer",@"ProductionTime"];
    //单元格文本框占位符
    cellPlaceholders = @[@"请输入批次编码",@"请输入供货量", @"请输入产品价格", @"请输入生产人", @"请输入生产日期"];
    
    if (!self.editingProID)//添加批次
    {
        self.title = @"添加批次";
    }
    else//编辑批次
    {
        self.title = @"编辑批次";
        batchInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
        //调用获取批次信息接口
        batchInfo = [_sharedClient getProductBatchInfoWithID:self.editingProID];
        NSLog(@"批次信息为%@", batchInfo);
        //批次编码
        _code = batchInfo[@"ProductBatchCode"];
        //批次内容
        _content = batchInfo[@"ProductBatchContent"];
        
        // todo
        contentDic = [_content JSONValue];
        contentString = [_content componentsSeparatedByString:@","];
        _deliquty = contentDic[@"Deliquty"];
        _unit = contentDic[@"DeliqutyUnit"];
        _price = contentDic[@"ProductPrice"];
        _producer = contentDic[@"Producer"];
        _proTime = contentDic[@"ProductTime"];
        addItemList = contentDic[@"CustomItems"];
        
    }
    
    //调用创建按钮方法
    [self createButton];
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenUnitView:)];
    //设置点击次数和点击手指数
    tapGesture.numberOfTapsRequired = 1; //点击次数
    tapGesture.numberOfTouchesRequired = 1; //点击手指数
    [self.view addGestureRecognizer:tapGesture];
    
    //创建一个消息通知中心，监听添加界面的值变更消息
    [DefaultNotificationCenter addObserver:self selector:@selector(insertItemCell:) name:@"newChose" object:nil];
    if (!self.editingProID)
    {
        //实例化可变数组
        addItemList = [NSMutableArray array];
    }
    proBatchTableView.allowsSelection=NO;
}

//消息通知中心响应方法
-(void)insertItemCell: (NSNotification *) notification
{
   
        newAddedItemDict = [notification.object copy];
        if (newAddedItemDict)
        {           
            //传需要的插入对象
            //[addItemList insertObject:newAddedItemDict atIndex:0];
            [addItemList addObject:newAddedItemDict];
           
            //表格视图开始更新
            [proBatchTableView beginUpdates];
            //插入一行
            [proBatchTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:addItemList.count - 1 inSection:1], nil] withRowAnimation:UITableViewRowAnimationRight];
            //表格视图结束更新
            [proBatchTableView endUpdates];
            //刷新表格视图
//            [proBatchTableView reloadData];
            //设置表格视图可以滚动
            proBatchTableView.scrollEnabled = YES;
        }
}

//手势识别器的回调方法，设置需要隐藏的视图
-(void)hidenUnitView:(UIView *)view
{
    _unitView.hidden = YES;
    _datePickerView.hidden = YES;
    //使供货量失去第一响应者
    [_deliqutyTextField resignFirstResponder];
    //使批次文本框失去第一响应者
    [_codeTextField resignFirstResponder];
    //使生产人文本框失去第一响应者
    [_producerTextField resignFirstResponder];
    //使产品价格文本框失去第一响应者
    [_productPriceTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
//返回分区数
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

//返回分区中的单元格数
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    else if(section == 1)
    {
        return addItemList.count;
    }
    else
    {
        return 1;
    }
}

//返回每个单元格的高度
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果在第二分区的第一行，就返回单元格高度为55
    if (indexPath.section == 2) {
        
        return 70;
    }
    if (indexPath.section == 1) {
        
        return 50;
    }
    return 44;
}

//给单元格添加数据
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //定义单元格标签标题标识符
    static NSString *cellIdentifier1 = @"cellLabelText";
    static NSString *cellIdentifier2 = @"cellLabelTextLabel";
    static NSString *cellIdentifier3 = @"cellLabelTextButton";
    static NSString *cellIdentifier4 = @"cellLabelButton";
    static NSString *cellIdentifier5 = @"cellViewLabel";
    
    
    //定义表格视图单元格
    UITableViewCell *cell;
    switch (indexPath.section)
    {
        //第一分区数据
        case 0:
            //批次编码，生产人单元格
            if (indexPath.row == ROW_CODE || indexPath.row == ROW_PRODUCER)
            {
                //这里是根据ID来创建不同的Cell实例
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
                
                //为单元格标签控件赋值
                UILabelWithTag(100).text = [cellTitles objectAtIndex: indexPath.row];
                
                //为单元格文本框控件添加占位符
                _codeAndProducerTextField = UITextFieldWithTag(200);
                _codeAndProducerTextField.placeholder = [cellPlaceholders objectAtIndex:indexPath.row];
                //如果是产品批次行，就通过新的tag值获取指定文本框
                if (indexPath.row == ROW_CODE)
                {
                    _codeAndProducerTextField.tag = 10;
                    _codeTextField = UITextFieldWithTag(10);
                    //编辑状态下，设置批次编码
                    if (self.editingProID)
                    {
                        _codeTextField.text = _code;
                    }
                    
                }
                //如果是生产人行，就通过新的tag值获取指定文本框
                else
                {
                    _codeAndProducerTextField.tag = 11;
                    _producerTextField = UITextFieldWithTag(11);
                    //编辑状态下，设置生产人
                    if (self.editingProID)
                    {
                        _producerTextField.text = _producer;
                    }
                }
                
            }
            else if(indexPath.row == ROW_PRODUCTPRICE)
            {
                //这里是根据ID来创建不同的Cell实例
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
                
                
                //为单元格标签控件赋值
                UILabelWithTag(101).text = [cellTitles objectAtIndex: indexPath.row];
                
                //为单元格文本框控件添加占位符
                _productPriceTextField = UITextFieldWithTag(201);
                _productPriceTextField.placeholder = [cellPlaceholders objectAtIndex:indexPath.row];
                //编辑状态下，设置生产价格
                if (self.editingProID)
                {
                    _productPriceTextField.text = _price;
                }
            }
            else if(indexPath.row == ROW_DELIQUTY || indexPath.row == ROW_PRODUCTIONTIME)
            {
                //这里是根据ID来创建不同的Cell实例
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
                
                //为单元格标签控件赋值
                UILabelWithTag(102).text = [cellTitles objectAtIndex: indexPath.row];
                
                //为单元格文本框控件添加占位符
                _deliqutyAndTimeTextField = UITextFieldWithTag(202);
                _deliqutyAndTimeTextField.placeholder = [cellPlaceholders objectAtIndex:indexPath.row];
//                _deliqutyAndTimeTextField.text = [proBatchDict objectForKey: [cellKeys objectAtIndex: indexPath.row]];
                
                //获取重用单元格上的按钮控件
                UIButton *button = UIButtonWithTag(300);
                //如果是供货量行，就为按钮设置标题为单位，及各种属性，并添加事件,并通过新的tag值获取文本框
                if (indexPath.row == ROW_DELIQUTY)
                {
                    //此判断保证按钮title不用每次都被初始化
                    if (_unitButton == nil)
                    {
                        button.tag = 400;
                        _unitButton = UIButtonWithTag(400);
                        [_unitButton setTitle:@"单位" forState:UIControlStateNormal];
                        [_unitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [_unitButton setBackgroundColor:UIColorFromRGB(0xE4E4E4)];
                        [_unitButton addTarget:self action:@selector(showUnit:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    _deliqutyAndTimeTextField.tag = 20;
                    _deliqutyTextField = UITextFieldWithTag(20);
                    //编辑状态下，设置供货量
                    if (self.editingProID)
                    {
                        _deliqutyTextField.text = _deliquty;
                        [_unitButton setTitle:_unit forState:UIControlStateNormal];
                    }
                    
                }
                //如果是生产日期行，就为按钮设置标题为选择日期，及各种属性，并添加事件
                else
                {
                    //设置生产日期文本框不可编辑
                    _deliqutyAndTimeTextField.enabled = NO;
                    _deliqutyAndTimeTextField.tag = 13;
                    _productionTimeTextField = UITextFieldWithTag(13);

                    [button setTitle:@"选择日期" forState:UIControlStateNormal];
                    [button setTitleColor:UIColorFromRGB(0xDEA931) forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
                    //编辑状态下，设置生产日期
                    if (self.editingProID)
                    {
                        _productionTimeTextField.text = _proTime;
                    }
                }
            }
            break;
        //第二分区数据
        case 1:
                if (addItemList.count > indexPath.row ) {
                    // todo 加上你要加的cell
                    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier5];
                    //从数组中获取用户输入的内容，字典类型
                    NSDictionary *custom = addItemList[indexPath.row];
                    NSString *ItemName = custom[@"ItemName"];
                    NSString *ItemValue = custom[@"ItemValue"];
                    //将内容设定给相对应的label文本
                    UILabelWithTag(701).text = ItemName;
                    UILabelWithTag(702).text = ItemValue;
                    //编辑状态下，设置添加选项
//                    if (self.editingProID != nil)
//                    {
//                        UILabelWithTag(701).text = _itemName;
//                        UILabelWithTag(702).text = _itemValue;
//                    }
                  }
            
            break;
        case 2:
            if (indexPath.row == 0) {
                //创建一个添加选项cell
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
            }
            
        default:
            break;
    }
    
    return cell;
}

//设置单元格修改或禁止选中
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//单位按钮事件
-(void)showUnit:(UIButton *)button
{
    [self.view addSubview:_unitView];
    _unitView.hidden = NO;
}


//选择日期按钮事件
-(void)showDatePicker:(UIButton *)button
{
    [self.view addSubview:_datePickerView];
    _datePickerView.hidden = NO;

}

//日期选择器选择完成后方法
- (IBAction)finishedDateSelected:(UIBarButtonItem *)sender
{
    //获取所选日期并转换成二进制格式    
    NSDate *date = _datePicker.date;
    NSLog(@"%@",_datePicker.date);
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy/MM/dd";
    _deliqutyAndTimeTextField.text = [fmt stringFromDate:date];
    _datePickerView.hidden = YES;
}

//循环创建8个按钮
-(void)createButton
{
    NSArray *btnTitle = @[@"克",@"斤",@"公斤",@"吨",@"包",@"箱",@"条",@"支"];
    for (int i = 0; i < btnTitle.count; i++)
    {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //title
        [_btn setTitle:[btnTitle objectAtIndex:i] forState:UIControlStateNormal];
        //frame
        [_btn setFrame:CGRectMake(0, 0+i*30, 100, 29)];
        //tag
        _btn.tag = i;
        //titlecolor
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //target
        [_btn addTarget:self action:@selector(unitChange:) forControlEvents:UIControlEventTouchUpInside];
        [_unitView addSubview:_btn];
    }

}

//随机选择单位后，将其文本更新到单位按钮文本
-(void)unitChange:(UIButton *)button
{
    self.btnText = [button titleForState:UIControlStateNormal];
    [_unitButton setTitle:self.btnText forState:UIControlStateNormal];
    _unitView.hidden = YES;
}

//保存按钮的操作方法
- (IBAction)saveData:(UIBarButtonItem *)sender
{
    //判断批次编码是否输入
    if ([_codeTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入批次编码" : nil];
        return;
    }
    //判断供货量是否输入
    if ([_deliqutyTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入供货量" : nil];
        return;
    }
    //保存单位按钮文本
    _unitButtonText = [_unitButton titleForState:UIControlStateNormal];
    //判断单位是否选择
    if ([_unitButtonText isEqualToString:@"单位"] )
    {
        [_commonUtils showMessageBox: @"请选择单位" : nil];
        return;
    }
    //判断产品价格是否输入
    if ([_productPriceTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入产品价格" : nil];
        return;
    }
    //判断生产人是否输入
    if ([_producerTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入生产人" : nil];
        return;
    }
    //判断生产日期是否选择
    if ([_productionTimeTextField.text length]<1)
    {
        [_commonUtils showMessageBox:@"请选择生产日期" : nil];
    }
    //显示保存图标
    [self showHUDWithMsg: @"保存中"];
    //用来保存选项名称
    NSString *itemNameText=@"";
    //用来保存内容
    NSString *itemValueText = @"";
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:_deliqutyTextField.text,@"Deliquty",_unitButtonText,@"DeliqutyUnit",_productPriceTextField.text,@"ProductPrice",_producerTextField.text,@"Producer",_productionTimeTextField.text ,@"ProductTime",addItemList,@"CustomItems",nil];
    
    
    NSString *itemListStr = [addItemList JSONRepresentation];
    // todo 确认格式
//    for (NSDictionary *textDic in addItemList ) {
//        itemListStr = [NSString stringWithFormat:@"%@|%@",itemListStr,[NSString stringWithFormat:@"%@,%@",textDic[@"ItemName"],textDic[@"ItemValue"]]];
//    }

     NSString *proBatchContent = [dic JSONRepresentation];
    //这里是调用产品批次接口，并且从服务器得到的数据，存放在proDict这个字典里
    proBatchDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    proBatchDict=[_sharedClient addWithBatchCode:_codeTextField.text andProductBatchContent:proBatchContent];
    //在编辑状态下，修改了内容之后，调用编辑批次接口
    if (self.editingProID != nil)
    {
        [_sharedClient editProductBatchWithId:self.editingProID andProductBatchCode:_code andProductBatchContent:proBatchContent];
        
    }
    //隐藏图标
    [self hideHUD];
    //回到上级界面
    [self.navigationController popViewControllerAnimated:YES];
    

}

@end
