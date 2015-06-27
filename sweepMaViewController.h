//
//  sweepMaViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/11.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface sweepMaViewController : BaseViewController
{
    __weak IBOutlet UITableView *sweepMaTableView;
    NSArray *cellTitles;//单元格标题
    NSArray *cellPlaceholders;//单元格占位符
    NSMutableArray *insertCellArray;//插入行数组
    
}
@property (weak, nonatomic)UITextField *proCodeText;
@property (weak, nonatomic)UITextField *proNameText;

@property (weak, nonatomic)UILabel *MaLabel;
@property (weak, nonatomic)UILabel *batchNameLabel;
@property (weak, nonatomic)UILabel *proNameLabel;
@property (weak, nonatomic)NSString *flag;
@property (weak, nonatomic)UIButton *sweepMaButton;


@end
