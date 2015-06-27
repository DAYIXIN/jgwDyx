//
//  ScannerViewController.h
//  supercode
//
//  Created by Alex on 15/6/8.
//  Copyright (c) 2015年 JiaGuWen. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
@class ScannerViewController;

@protocol ScannerViewControllerDelegate <NSObject>

@required
-(NSString *) scannerViewController: (ScannerViewController *) scanner code: (NSString *) code;

@end

@interface ScannerViewController : BaseViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    NSString * lastCode1, *lastCode2, *lastCode3;
    UILabel * hintLabel;
    AVCaptureDevice *captureDevice;
    
}

@property (weak, nonatomic) id <ScannerViewControllerDelegate> delegate;
@property int tag;

@end
