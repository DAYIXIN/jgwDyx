//
//  ScanViewController.h
//  saoma
//
//  Created by chenpeng on 15/6/26.
//  Copyright (c) 2015年 chenpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanView.h"
#import "BaseViewController.h"
@interface ScanViewController : BaseViewController

@property (nonatomic, strong) IBOutlet  UIView  *readerView;

@property (nonatomic, assign) BOOL torchMode;        //控制闪光灯的开关

@property(nonatomic, copy)void(^scanBlock)(NSString* scanCode);

@end
