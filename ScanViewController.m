//
//  ScanViewController.m
//  saoma
//
//  Created by chenpeng on 15/6/26.
//  Copyright (c) 2015年 chenpeng. All rights reserved.
//

#import "ScanViewController.h"



@interface ScanViewController ()<ScanViewDelegate>
{
    ScanView *   iosScanView;
    AVCaptureSession *session;
}

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"条码";
    
    //默认关闭闪光灯
    self.torchMode = NO;
   
        iosScanView = [[ScanView alloc] initWithFrame:self.readerView.frame];
        iosScanView.delegate = self;
        [self.view addSubview:iosScanView];

    [self configureReadView];
    [self setupTorchBarButton];
    [self setupDynamicScanFrame];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.useType = Enum_Scan_Items_Preferential;
    if (iosScanView) {
        [iosScanView startRunning];
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (iosScanView) {
        [iosScanView stopRunning];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark  初始化界面布局

- (void)configureReadView
{
    UILabel *desrciption = [[UILabel alloc] initWithFrame:CGRectMake(60, 380, 200, 35)];
    desrciption.textColor =[UIColor redColor];
    desrciption.font = [UIFont systemFontOfSize:13.0f];
    desrciption.text = @"将条码放到取景框内,即可自动扫描";
    [self.view addSubview:desrciption];
}

- (void)setupDynamicScanFrame
{
    CGRect scanMaskRect = CGRectMake(0, 0, 200, 200);
    UIImageView *scanImage = [[UIImageView alloc] initWithFrame:scanMaskRect];
    [scanImage setImage:[UIImage imageNamed:@"扫描框"]];
    [self.view addSubview:scanImage];
    scanImage.center = CGPointMake(self.view.center.x, self.view.center.y-61);
    
    UIImageView *scanLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 6)];
    [scanLineImage setImage:[UIImage imageNamed:@"扫描线"]];
    [self.view addSubview:scanLineImage];
    scanLineImage.center = CGPointMake(self.view.center.x, self.view.center.y-100-61);
    
    [self runSpinAnimationOnView:scanLineImage duration:3 positionY:200 repeat:CGFLOAT_MAX];
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration positionY:(CGFloat)positionY repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: positionY];
    rotationAnimation.duration = duration;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.autoreverses = YES;
    [view.layer addAnimation:rotationAnimation forKey:@"position"];
}

#pragma mark -
#pragma mark  右上角按钮 闪光灯
- (void)setupTorchBarButton
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Torch.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleTorch:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)toggleTorch:(id)sender
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!self.torchMode) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                self.torchMode = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                self.torchMode = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark -
#pragma mark  扫码结果回调

- (void) IOSScanResult: (NSString*) scanCode
{
    //进行业务逻辑处理
    [self DealResult:scanCode];
}

#pragma mark  根据扫描结果进行业务逻辑处理
- (void)DealResult:(NSString *)scanCode
{
    
    NSLog(@"%@",scanCode);
    
}

@end
