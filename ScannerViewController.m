//
//  ScannerViewController.m
//  supercode
//
//  Created by Alex on 15/6/8.
//  Copyright (c) 2015年 JiaGuWen. All rights reserved.
//

#import "ScannerViewController.h"

@interface ScannerViewController ()

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(BOOL)startReading;

-(void)stopReading;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isReading = NO;
    self.captureSession = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isReading)
    {
        if ([self startReading])
        {
        }
    }
    else
    {
        [self stopReading];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self stopReading];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)startReading
{
    NSError *error;
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    /*
    if ([captureDevice hasTorch] && [captureDevice hasFlash])
    {
        [captureDevice lockForConfiguration:nil];
//        [captureDevice setFlashMode: AVCaptureFlashModeAuto];
        [captureDevice setTorchMode: AVCaptureTorchModeAuto];
        [captureDevice unlockForConfiguration];
    }
    */
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
    {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code]];
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame: self.view.layer.bounds];
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    
#define topHeight 84
#define bottomHeight 148
#define cornerLength 24
#define middleLength 136
#define cornerMargin 36
#define roundWidth 180
#define roundHeight 60
    
    CGRect frame = self.view.frame;
    [_commonUtils myLogRect: 3 : frame];
    if (iOS6)
        frame.size.height += 20;
    
    { //上方半透明挡板
        UIImageView * topMaskImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, topHeight)];
        topMaskImageView.backgroundColor = [UIColor lightGrayColor];
        topMaskImageView.alpha = 0.8;
        topMaskImageView.autoresizingMask = 34;
        [self.view addSubview: topMaskImageView];
    }
    
    { //下方半透明挡板
        UIImageView * bottomMaskImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, frame.size.height-bottomHeight, frame.size.width, bottomHeight)];
        bottomMaskImageView.backgroundColor = [UIColor lightGrayColor];
        bottomMaskImageView.alpha = 0.8;
        bottomMaskImageView.autoresizingMask = 10;
        [self.view addSubview: bottomMaskImageView];
    }
    
    { //左上角竖线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(cornerMargin, topHeight, 1, cornerLength)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 36;
        [self.view addSubview: redLineView];
    }
    
    { //左上角横线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(cornerMargin, topHeight, cornerLength, 1)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 36;
        [self.view addSubview: redLineView];
    }
    
    { //右上角竖线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(frame.size.width-cornerMargin, topHeight, 1, cornerLength)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 33;
        [self.view addSubview: redLineView];
    }
    
    { //右上角横线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(frame.size.width-cornerMargin-cornerLength, topHeight, cornerLength, 1)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 33;
        [self.view addSubview: redLineView];
    }
    
    { //左下角竖线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(cornerMargin, frame.size.height-bottomHeight-cornerLength-1, 1, cornerLength)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 12;
        [self.view addSubview: redLineView];
    }
    
    { //左下角横线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(cornerMargin, frame.size.height-bottomHeight-1, cornerLength, 1)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 12;
        [self.view addSubview: redLineView];
    }
    
    { //右下角竖线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(frame.size.width-cornerMargin, frame.size.height-bottomHeight-cornerLength-1, 1, cornerLength)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 9;
        [self.view addSubview: redLineView];
    }
    
    { //右下角横线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake(frame.size.width-cornerMargin-cornerLength, frame.size.height-bottomHeight-1, cornerLength, 1)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 9;
        [self.view addSubview: redLineView];
    }
    
    { //中间红线
        UIView * redLineView = [[UIView alloc] initWithFrame: CGRectMake((frame.size.width-middleLength)/2, topHeight+(frame.size.height-bottomHeight-topHeight)/2, middleLength, 1)];
        redLineView.backgroundColor = [UIColor redColor];
        redLineView.autoresizingMask = 45;
        [self.view addSubview: redLineView];
    }
    
    { //文字面板
        UIView * roundView = [[UIView alloc] initWithFrame: CGRectMake((frame.size.width-roundWidth)/2, frame.size.height-(bottomHeight-roundHeight)/2-roundHeight, roundWidth, roundHeight)];
        roundView.layer.cornerRadius = 6.0;
        roundView.layer.masksToBounds = YES;
        roundView.backgroundColor = [UIColor whiteColor];
        roundView.autoresizingMask = 10;
        [self.view addSubview: roundView];
        
        UILabel * label1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 13, roundWidth, 15)];
        label1.text = @"条码 / 二维码";
        label1.textColor = UIColorFromRGB(0x727272);
        label1.font = [UIFont systemFontOfSize: 13];
        label1.textAlignment = NSTextAlignmentCenter;
        [roundView addSubview: label1];
        
        UILabel * label2 = [[UILabel alloc] initWithFrame: CGRectMake(0, 33, roundWidth, 13)];
        label2.text = @"防伪、物流、溯源、积分查询";
        label2.textColor = UIColorFromRGB(0x727272);
        label2.font = [UIFont systemFontOfSize: 10];
        label2.textAlignment = NSTextAlignmentCenter;
        [roundView addSubview: label2];
    }
    
    hintLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 20, self.view.frame.size.width-10, 40)];
    hintLabel.numberOfLines = 3;
    hintLabel.textColor = [UIColor blackColor];
    hintLabel.font = [UIFont systemFontOfSize: 16];
    hintLabel.textAlignment = NSTextAlignmentCenter;
//    hintLabel.text = @"aaaaa";
    [self.view addSubview: hintLabel];

    [_captureSession startRunning];
    return YES;
}

-(void)stopReading
{
    [self.captureSession stopRunning];
    
    self.captureSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
    
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataMachineReadableCodeObject *metadataObj in metadataObjects)
    {
        NSString * code = [metadataObj stringValue];
        if (!([code isEqualToString: lastCode1] || [code isEqualToString: lastCode2] || [code isEqualToString: lastCode3]))
        {
            lastCode3 = lastCode2;
            lastCode2 = lastCode1;
            lastCode1 = code;
            NSLog(@"扫码得到：%@", code);
            
            [hintLabel performSelectorOnMainThread:@selector(setText:) withObject: [self.delegate scannerViewController: self code: code] waitUntilDone:YES];
        }
    }
    
    
    /*
     return;
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
//            [self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            NSURL *url = [NSURL URLWithString:[metadataObj stringValue]];
            if (url)
                
                [self performSelectorOnMainThread:@selector(goToURL:) withObject:url waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[self.startButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
        }
    }
     */
}

-(IBAction) turnTorchOnOff:(id)sender
{
    if ([captureDevice hasTorch] && [captureDevice hasFlash])
    {
        UIBarButtonItem * onOffButton = (UIBarButtonItem *) sender;
        
        if (captureDevice.torchMode == AVCaptureTorchModeOff)
        {
            [onOffButton setTitle: @"关灯"];
            [captureDevice lockForConfiguration:nil];
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
            [captureDevice setFlashMode:AVCaptureFlashModeOn];
            [captureDevice unlockForConfiguration];
        }
        else
        {
            [onOffButton setTitle: @"开灯"];
            [captureDevice lockForConfiguration:nil];
            [captureDevice setTorchMode:AVCaptureTorchModeOff];
            [captureDevice setFlashMode:AVCaptureFlashModeOff];
            [captureDevice unlockForConfiguration];
        }
    }
}

@end
