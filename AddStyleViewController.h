//
//  AddStyleViewController.h
//  daYiXin
//
//  Created by JGW on 15/6/25.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "BaseViewController.h"

@interface AddStyleViewController : BaseViewController
{
    
    __weak IBOutlet UITableView *addStyleTableView;
    NSMutableArray *sectionArray;//接收服务器返回信息
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editOrSaveButton;

@property (weak, nonatomic)UILabel *sonClassLabel;
- (IBAction)editOrSaveBarButtonItem:(UIBarButtonItem *)sender;




@end
