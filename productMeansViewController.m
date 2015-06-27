//
//  productMeansViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/11.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "productMeansViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"

@interface productMeansViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableview;

@end

@implementation productMeansViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myTableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view.
    //当视图将要出现时，设置导航栏不隐藏
    [self viewWillAppear:YES];
    
    //准备数据，实际需要你通过接口从服务器获取
//    proMeansList = [[NSMutableArray alloc] init];
//    [proMeansList addObject: @{@"aaaa": @"11111", @"bbbb": @"one"}];
//    [proMeansList addObject: @{@"aaaa": @"22222", @"bbbb": @"two"}];
//    [proMeansList addObject: @{@"aaaa": @"33333", @"bbbb": @"three"}];

}

//视图将要出现方法，获取产品列表，加载到界面显示
-(void)viewDidAppear:(BOOL)animated
{
    proMeansList = [[NSMutableDictionary alloc]init];
    //调用获取产品列表接口，返回值为字典
    proMeansList = [_sharedClient getProductListWithPageSize:20 andPageNum:1];
    //用来获取字典中的第二个元素，数组类型
    proMeansArray = proMeansList[@"Rows"];
    
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
    return [proMeansArray count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建cell标识符
    static NSString * cellIdentifier = @"proListCell";
    //创建重用cell
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    //根据索引获得所对应的字典信息
    proContents = proMeansArray[indexPath.row];
    _proCodeString = proContents[@"ProductCode"];
    _proNameString= proContents[@"ProductName"];
    //获取标签控件
    _proCodeLabel = UILabelWithTag(20);
    _proNameLabel = UILabelWithTag(30);
    //为标签控件添加文本
    _proCodeLabel.text = _proCodeString;
    _proNameLabel.text = _proNameString;
    
    return cell;
}



@end
