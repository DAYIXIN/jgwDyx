//
//  historyMaViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/12.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "historyMaViewController.h"
#import "ProBatchViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"

@interface historyMaViewController ()<UITabBarControllerDelegate,UITableViewDataSource>
{
    BOOL log;
}

@end

@implementation historyMaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewWillAppear:YES];
    log = YES;
    _flag = @"0";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"%@",NSStringFromCGRect(historyMaTableView.frame));
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
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if(section == 1)
    {
        return 1;
    }
    else
    {
        return insertCellArray.count+1;
    }
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        return 30;
    }
    return 44;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    //创建cell标识符
    static NSString *cellIdentifier1 = @"cellLabelText";
    static NSString *cellIdentifier2 = @"cellLabelButton";
    static NSString *cellIdentifier3 = @"cellButton";
    static NSString *cellIdentifier4 = @"cellLabel";   
    
    switch (indexPath.section)
    {
        case 0:
            
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier1];
                UILabelWithTag(10).text = @"产品批次:";
                UITextFieldWithTag(11).placeholder = @"请选择产品批次";                UITextFieldWithTag(11).enabled = NO;
                _proBatchText = UITextFieldWithTag(11);
                
//                _proCodeText = UITextFieldWithTag(11);
//                _proCodeText.tag = 40;
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier2];
                UILabelWithTag(20).text = @"上传时间:";
                [UIButtonWithTag(21) setTitle:@"请选择日期" forState:UIControlStateNormal];
                [UIButtonWithTag(22) setTitle:@"请选择日期" forState:UIControlStateNormal];
                _choseDateOneButton = UIButtonWithTag(21);
                _choseDateTwoButton = UIButtonWithTag(22);
                //为选择日期按钮添加事件
                [_choseDateOneButton addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
                [_choseDateTwoButton addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
//                _proNameText = UITextFieldWithTag(61);
//                _proNameText.tag = 41;
            }
            
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier3];
            _checkButton = UIButtonWithTag(30);
            //为查询按钮添加事件
            [_checkButton addTarget:self action:@selector(showMaInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier4];
            if (indexPath.row == 0)
            {
                _MaLabel = UILabelWithTag(40);
                _MaLabel.tag = 50;
                _MaLabel.text = @"二维码";
                //设置标签文本居中
                _MaLabel.textAlignment = NSTextAlignmentCenter;
                _batchNameLabel = UILabelWithTag(41);
                _batchNameLabel.tag = 51;
                _batchNameLabel.text = @"批次名称";
                _batchNameLabel.textAlignment = NSTextAlignmentCenter;
                _proNameLabel = UILabelWithTag(42);
                _proNameLabel.tag = 52;
                _proNameLabel.text = @"产品名称";
                _proNameLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

//实现查询按钮点击方法
-(void)showMaInfo:(UIButton *)button
{
    NSDictionary *cus = [_sharedClient getLogisticsCodeListWithpageSize:20 andPageNum:1];
    
}

//对表格视图里行选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier: @"segueBatchList" sender:indexPath];
    
}

// 此方法在视图切换前调用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"segueBatchList"])
    {
        // 得到目标视图
        ProBatchViewController *viewController = (ProBatchViewController *)segue.destinationViewController;
        viewController.flag = _flag;
        viewController.passProBatchBlock = ^(NSString *code){
            [_proBatchText setText:code];
        };
    }
   
}



//选择日期按钮事件
-(void)showDatePicker:(UIButton *)button
{
    [self.view addSubview:datePickerView];
    datePickerView.hidden = NO;
    
}

//日期选择器选择完成后方法
- (IBAction)finishedDateSelected:(UIBarButtonItem *)sender
{
    //获取所选日期并转换成二进制格式
    NSDate *date = datePicker.date;
    NSLog(@"%@",datePicker.date);
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy/MM/dd";
    if (log == YES)
    {
        [_choseDateOneButton setTitle:[fmt stringFromDate:date] forState:UIControlStateNormal];
        log = NO;
    }
    else{
        
        [_choseDateTwoButton setTitle:[fmt stringFromDate:date] forState:UIControlStateNormal];
        log = YES;
    }
    
    datePickerView.hidden = YES;
}


//设置单元格修改或禁止选中
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return indexPath;
        }
    }    
    return nil;
}


@end
