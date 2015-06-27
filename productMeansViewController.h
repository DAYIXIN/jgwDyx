//
//  productMeansViewController.h
//  daYiXin
//
//  Created by JGW on 15/5/11.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface productMeansViewController : BaseViewController
{
    NSDictionary * proMeansList; //把通过接口从服务器获取的产品批次存这里
    NSMutableArray *proMeansArray; //用来存放接口返回值的第二个元素，数组类型
    NSDictionary *proContents;//用来存放数组中的单个字典信息
}

@property (weak, nonatomic)NSString *imageUrl;
@property (weak, nonatomic)NSString *proCodeString; //产品编码字符串
@property (weak, nonatomic)NSString *proNameString; //产品名称字符串

@property (weak, nonatomic)UILabel *proCodeLabel; //产品编码
@property (weak, nonatomic)UILabel *proNameLabel; //产品名称

@end
