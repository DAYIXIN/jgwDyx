
//
//  ProBatchViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/22.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "ProBatchViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"
#import "XAddProBatchViewController.h"
#import "sweepMaViewController.h"
#import "historyMaViewController.h"


@interface ProBatchViewController () <UITableViewDataSource, UITableViewDelegate>
{
   
}

@end

@implementation ProBatchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //调用基类方法，视图将要出现时，设置导航栏不隐藏
    [self viewWillAppear:YES];
    //我造两个数据，实际需要你通过接口从服务器获取
//    [proBatchList addObject: @{@"aaaa": @"000001", @"xxxx": @"2015-04-13"}];
//    [proBatchList addObject: @{@"aaaa": @"000002", @"xxxx": @"2015-04-14"}];
//    [proBatchList addObject: @{@"aaaa": @"000003", @"xxxx": @"2015-04-15"}];
}

//视图出现方法，获取批次列表，加载到界面显示
-(void)viewDidAppear:(BOOL)animated
{
    
    proBatchInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    //调用获取批次列表接口，pagesize每页显示数据，pagenum当前页码
    //用来存放服务器返回值，字典类型
    proBatchInfo = [_sharedClient getProductBatchListWithPageSize:20 andPageNum:1];
    //NSLog(@"--%@--", proBatchInfo);
    //获取字典中的第二个元素，返回值为数组
    proBatchList = proBatchInfo[@"Rows"];
    //NSLog(@"==%@==id不为空",self.editingProID);

    //刷新表格视图
    [batchListTableView reloadData];
    //设置表格视图可以滚动
    batchListTableView.scrollEnabled = YES;
    
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

#pragma mark - UITableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [proBatchList count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建cell标识符
    static NSString * cellIdentifier = @"cellLabel";
    //创建重用cell
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    //根据索引获得所对应的字典信息
    custom = proBatchList[indexPath.row];
    _proBatchCode = custom[@"ProductBatchCode"];
    _createTime = custom[@"CreateTime"];
    //为标签添加文本
     UILabelWithTag(100).text = _proBatchCode; //产品批次
     UILabelWithTag(200).text = _createTime; //创建时间
    
    return cell;
}

//对表格视图里行选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //弹出扫码历史界面，并获取批次编码
    if ([_flag isEqualToString:@"0"])
    {
        //定义一个字典用来接收单元格行的内容
         NSDictionary *selectedBatch = proBatchList[indexPath.row];
        
        if (self.passProBatchBlock)
        {
            self.passProBatchBlock(selectedBatch[@"ProductBatchCode"]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    //弹出扫码界面，并获取批次编码
    else if ([_flag isEqualToString:@"1"])
    {
        NSDictionary *selectedBatch = proBatchList[indexPath.row];
        
        if (self.passProBatchBlock)
        {
            self.passProBatchBlock(selectedBatch[@"ProductBatchCode"]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier: @"segueAddProBatch" sender:indexPath];
    }
    
}

// 此方法在视图切换前调用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{// todo
    //判断如果为扫码历史界面，就传值
    if ([_flag isEqualToString:@"0"])
    {
//        historyMaViewController *historyCtrl = (historyMaViewController *)segue.destinationViewController;
//        historyCtrl.proBatchText.text = _proBatchCode;
    }
    else if([_flag isEqualToString:@"1"])
    {
//        sweepMaViewController *sweepCtrl = (sweepMaViewController *)segue.destinationViewController;
//        sweepCtrl.proCodeText.text = _proBatchCode;
    }
    
    else
    {
    // 得到目标视图
    XAddProBatchViewController *viewController = (XAddProBatchViewController *)segue.destinationViewController;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        viewController.editingProID = nil;
        return;
    }
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        if (((NSIndexPath *)sender).row < proBatchList.count) {
            // 传参
            //获取数组中的第一个元素，产品批次id
            NSDictionary *cus;
            cus = proBatchList[((NSIndexPath *)sender).row];
            //定义一个字符串来接收获取到的产品id
            viewController.editingProID = cus[@"ProductBatchID"];
        }
        return;
    }
        
    }
}

//点击后弹出添加批次界面
- (IBAction)addButtonEvent:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier: @"segueAddProBatch" sender:nil];
}

@end
