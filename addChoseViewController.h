//
//  addChoseViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/13.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface addChoseViewController : BaseViewController
{
    NSMutableDictionary *CustomItems;
}

- (IBAction)finishedAddButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *ItemName;
@property (weak, nonatomic) IBOutlet UITextField *ItemValue;


@end
