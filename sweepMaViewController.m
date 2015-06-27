//
//  sweepMaViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/11.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "sweepMaViewController.h"
#import "XAddProBatchViewController.h"
#import "AddProductMeansViewController.h"
#import "ProBatchViewController.h"
#import "ZBarSDK.h"
#import "ScanViewController.h"
@interface sweepMaViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
}

@end

@implementation sweepMaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    //设置按钮边框宽度
//    self.sweepMa.layer.borderWidth = 2.0;
//    //设置按钮边框颜色
//    self.sweepMa.layer.borderColor = [UIColorFromRGB(0xDEA931)CGColor];
    [self viewWillAppear:YES];
    cellTitles = @[@"产品批次:",@"产品名称:"];
    cellPlaceholders = @[@"请选择产品批次",@"请选择产品名称"];
    _flag = @"1";    
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
    static NSString *cellIdentifier2 = @"cellButton";
    static NSString *cellIdentifier3 = @"cellLabel";
    static NSString *cellIdentifier4 = @"cellLabelTextTwo";
    
    switch (indexPath.section)
    {
        case 0:
            //产品批次行
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier1];
                UILabelWithTag(10).text = [cellTitles objectAtIndex: indexPath.row];
                UITextFieldWithTag(11).placeholder = [cellPlaceholders objectAtIndex:indexPath.row];
                UITextFieldWithTag(11).enabled = NO;
                _proCodeText = UITextFieldWithTag(11);
                _proCodeText.tag = 40;
            }
            //产品名称行
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier4];
                UILabelWithTag(60).text = [cellTitles objectAtIndex: indexPath.row];
                UITextFieldWithTag(61).placeholder = [cellPlaceholders objectAtIndex:indexPath.row];
                UITextFieldWithTag(61).enabled = NO;
                _proNameText = UITextFieldWithTag(61);
                _proNameText.tag = 41;
            }
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier2];
            _sweepMaButton = UIButtonWithTag(20);
            [_sweepMaButton addTarget:self action:@selector(sweepMa:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier3];
            if (indexPath.row == 0)
            {
                _MaLabel = UILabelWithTag(30);
                _MaLabel.tag = 50;
                _MaLabel.text = @"二维码";
                //设置标签文本居中
                _MaLabel.textAlignment = NSTextAlignmentCenter;
                _batchNameLabel = UILabelWithTag(31);
                _batchNameLabel.tag = 51;
                _batchNameLabel.text = @"批次名称";
                _batchNameLabel.textAlignment = NSTextAlignmentCenter;
                _proNameLabel = UILabelWithTag(32);
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

//设置单元格修改或禁止选中
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section == 0)
        {
            return indexPath;
        }
    
    return nil;
}

//实现扫码按钮点击方法
-(void)sweepMa:(UIButton *)button
{
    //载入二维码扫描界面
    ScanViewController *scan=[[ScanViewController alloc]initWithNibName:@"ScanViewController" bundle:nil];
    [self.navigationController pushViewController:scan animated:YES];

}

//对表格视图里行选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier: @"segueBatchList" sender:indexPath];
    
}

// 此方法在视图切换前调用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"segueBatchListOne"])
    {
        // 得到目标视图
        ProBatchViewController *viewController = (ProBatchViewController *)segue.destinationViewController;
        viewController.flag = _flag;
        //为回调函数初始化
        viewController.passProBatchBlock = ^(NSString *code){
            [_proCodeText setText:code];};

    }
    
}
@end
