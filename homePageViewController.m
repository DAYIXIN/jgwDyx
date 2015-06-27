//
//  homePageViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/8.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "homePageViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"
#import "SDCycleScrollView.h"

@interface homePageViewController ()<SDCycleScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation homePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //定义数组，用来存放轮播图片
    NSArray *images = @[[UIImage imageNamed:@"帮助"],
                        [UIImage imageNamed:@"产品批次"]];
    //创建图片轮播器
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, APP_W, 171) imagesGroup:images];
    cycleScrollView.delegate = self;
    [self.backView addSubview:cycleScrollView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//视图将要出现方法,隐藏导航栏
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//版本更新按钮点击方法
- (IBAction)newEdition:(UIButton *)sender
{
    [self showHUDWithMsg: @"当前版本已是最新版本"];
    [self hideHUD];

}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", index);
}
@end
