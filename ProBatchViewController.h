//
//  ProBatchViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/22.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


//一个回调，用来传值
typedef void(^passProBatchBlock)(NSString *proCode);

@interface ProBatchViewController : BaseViewController
{
    NSArray * proBatchList; //用来存放服务器返回数据的第二个元素，数组类型
    NSDictionary *proBatchInfo;//用来存放获取到批次信息
    NSDictionary *custom;    
    __weak IBOutlet UITableView *batchListTableView;
    
}

@property (weak,nonatomic)NSString *proBatchCode;//用来存放产品批次
@property (weak,nonatomic)NSString *createTime;//用来存放创建时间
@property (weak, nonatomic)NSString *editingProID;//编辑中产品id
@property (weak, nonatomic)NSString *flag;

//定义一个回调方法类型的实例
@property (copy, nonatomic) passProBatchBlock passProBatchBlock;

- (IBAction)addButtonEvent:(UIBarButtonItem *)sender;

@end
