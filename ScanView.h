//
//  ScanView.h
//  saoma
//
//  Created by chenpeng on 15/6/26.
//  Copyright (c) 2015年 chenpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScanViewDelegate < NSObject >

- (void) IOSScanResult: (NSString*) scanCode;

@end

@interface ScanView : UIView<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic ,weak) id<ScanViewDelegate>delegate;

- (void)startRunning;
- (void)stopRunning;

@end
