//
//  baseMeansViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/12.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface baseMeansViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary *loginInfo;//用来存放登录后返回值信息，字典类型

    __weak IBOutlet UITableView *baseMeansTableView;
}
- (IBAction)editAndSaveEventBarButtonItem:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editOrSaveBarButtonItem;
@property (weak, nonatomic) UITextField *baseName;
@property (weak, nonatomic) UITextField *baseIntroduce;

@end
