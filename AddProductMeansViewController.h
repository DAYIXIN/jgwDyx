//
//  AddProductMeansViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/26.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "BaseViewController.h"


@interface AddProductMeansViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UIBarButtonItem *saveButton;//保存按钮
    __weak IBOutlet UITableView *proMeansTableView; //表格视图
    NSArray *cellTitles; //单元格标题数组
    NSArray *cellKeys; //单元格数据key值数组
    NSArray *cellPlaceholders; //单元格占位符数组
    NSMutableDictionary *proMeansDict;//通过服务器获取到的产品信息存放到字典中
//    NSString *autoSaveKey; //自动存储key值的字符串
    NSMutableArray *saveImage;//保存图片数组
    
    BOOL editing;//状态

}

@property (weak, nonatomic)NSString *editingProID;//编辑中产品id
@property (weak, nonatomic)UITextField *proNameTextField;//产品名称
@property (weak, nonatomic)UITextField *proStyleTextField;//产品类型
@property (weak, nonatomic)UITextField *proCodeTextField;//产品编号
@property (weak, nonatomic)UITextField *proIntroduceTextField;//产品介绍

//@property (weak, nonatomic)UIButton *addImageButton1;//添加图片按钮
//@property (weak, nonatomic)UIButton *addImageButton2;//添加图片按钮
//@property (weak, nonatomic)UIButton *addImageButton3;//添加图片按钮
- (IBAction)saveDataBarButtonItem:(UIBarButtonItem *)sender;


@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic)UIImage *image;
@property (weak, nonatomic) IBOutlet UIView *showImageTableViewView;

-(void)showActionSheet;
-(void)showAlertToDelete;



@end
