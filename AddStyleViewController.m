//
//  AddStyleViewController.m
//  daYiXin
//
//  Created by JGW on 15/6/25.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "AddStyleViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"

@interface AddStyleViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL selected;
    NSMutableArray *sonClassArray; //用来接收二级分类类目的可变数组
    UIButton *addSonButton;//加子类按钮
    UIButton *deleteButton; //删除按钮
    UIButton *sonDeleteButton;//子类删除按钮
    UITextField *addFatherItemtextField;
}
@property (nonatomic,strong)UIView *HeaderView;
@end

@implementation AddStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    addStyleTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    // Do any additional setup after loading the view.
    //初始化导航栏按钮标题
    [_editOrSaveButton setTitle:@"编辑"];
    selected = YES;
    sectionArray = [NSMutableArray array];
    sonClassArray = [NSMutableArray array];
    
    //调用初始化头视图方法
    [self initTableHead];
    
    //调用获取分类列表接口
    sectionArray = [_sharedClient getProductClassify];
    
}


//初始化表格头视图，一个文本框，一个按钮
-(void)initTableHead
{
        self.HeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,40)];
        addFatherItemtextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, 250, 35)];
        addFatherItemtextField.layer.borderWidth = 1.0f;
        addFatherItemtextField.layer.cornerRadius = 5;
        addFatherItemtextField.placeholder = @"请输入1级分类的名称";
        
        UIButton *addbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addbutton.frame = CGRectMake(265, 5, 50, 35);
        [addbutton setTitle:@"添加" forState:UIControlStateNormal];
        [addbutton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [addbutton.layer setBorderWidth:1.0]; //边框宽度
    //点击添加按钮，添加一级类目
    [addbutton addTarget:self action:@selector(addFatherItem:) forControlEvents:UIControlEventTouchUpInside];
    
        [self.HeaderView addSubview:addFatherItemtextField];
        [self.HeaderView addSubview:addbutton];
}

//点击添加一级分类的方法
-(void)addFatherItem:(UIButton *)button
{
    //获取文本输入框内容
    NSString *fatherItemString = addFatherItemtextField.text;
    
}

- (void)didReceiveMemoryWarning
{
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

//返回单元格的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

//显示表格视图中的分区数量
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionArray.count;
}

//显示分区中单元格的数量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sonClassArray.count;
}

//设置分区头的内容
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //设置分区头view
    UIView *headView=[[UIView alloc]init];
    UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, 200, 30)];
    [headView addSubview:lable];
    lable.text=[sectionArray objectAtIndex:section][@"ClassifyName"];
   
    //设置添加子类按钮
    addSonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addSonButton.frame = CGRectMake(210, 5, 60, 30);
    [addSonButton setTitle:@"加子类" forState:UIControlStateNormal];
    addSonButton.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    [addSonButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [addSonButton addTarget:self action:@selector(addCell:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置删除按钮
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(280, 5, 30, 30);
//    [deleteButton setImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
    [headView addSubview:deleteButton];
    [headView addSubview:addSonButton];
    
    //导航栏按钮标题为编辑时，隐藏添加子类和删除按钮
    if (selected)
    {
        deleteButton.hidden=YES;
        addSonButton.hidden=YES;
    }
    else
    {
        deleteButton.hidden=NO;
        addSonButton.hidden=NO;
    }
    return headView;
}

//显示分区头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


//给单元格添加数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建自定义单元格
    static NSString *cellIndentifer = @"cellLabel";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndentifer];
    if (cell==nil) {
        cell=[[NSBundle mainBundle]loadNibNamed:@"TableViewCell" owner:self options:nil][0];
    }
    
    sonClassArray = [sectionArray objectAtIndex:indexPath.section][@"SubItems"];
    //获取分区单元格的label
    _sonClassLabel = UILabelWithTag(1100);
    //获取分区下的子类删除按钮
    sonDeleteButton = UIButtonWithTag(1200);
    if (selected)
    {
        sonDeleteButton.hidden = YES;
    }
    else
    {
        sonDeleteButton.hidden = NO;
    }
    _sonClassLabel.text = [sonClassArray objectAtIndex:indexPath.row];
    return cell;
}


//添加cell方法
-(void)addCell:(id)sender{
//    [self.cellArray addObject:@"你好"];
//    [self.listView reloadData];
}

//导航栏按钮响应方法
- (IBAction)editOrSaveBarButtonItem:(UIBarButtonItem *)sender
{
    //当判断值为no时，设置导航栏标题为保存，并显示自定义头视图
    if (selected)
    {
        selected = NO;
        [_editOrSaveButton setTitle:@"保存"];
        addStyleTableView.tableHeaderView=self.HeaderView;
    }
    else //当判断值为yes时，设置导航栏标题为编辑，并设置头视图为空
    {
        
        selected = YES;
        [_editOrSaveButton setTitle:@"编辑"];
        addStyleTableView.tableHeaderView=nil;
    }
    //刷新表格视图
    [addStyleTableView reloadData];
}
@end
