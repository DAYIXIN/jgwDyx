//
//  baseMeansViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/12.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "baseMeansViewController.h"
#import "loginViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"
#import "SelectedPictureItem.h"

#define ROW_BASENAME 0
#define ROW_BASEINTRODUCE 1
#define ROW_BASEPHOTO 2


//红定义，图片显示数量
#define MAX_PHOTO_NUMBER 3

//@interface BaseSelectedPictureItem : NSObject
//@property (nonatomic, strong) UIImage *uploadImage;//图片信息
//@property (nonatomic, assign) NSInteger upLoadStatus;//1 - 没上传 2-上传成功 3- 上传失败 4 - 上传中
//@property (nonatomic, assign) BOOL isCameraItem;//判断是否是相机拍摄
//@end
//
//@implementation SelectedPictureItem
//
//
//
//@end


@interface baseMeansViewController ()<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    NSString *filePath; //图片存储路径
    NSMutableArray *imageArray; //图片数组
    NSMutableArray *buttonArray; //按钮数组
}
//定义一个滚动视图
@property (nonatomic, strong) UIScrollView *imageContainer;

@end

@implementation baseMeansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //视图将要出现方法,不隐藏导航栏
    [self viewWillAppear:YES];
    baseMeansTableView.scrollEnabled = NO;
    //调用初始化图片数据方法
    [self configImageData];
}

#pragma mark 图片处理相关逻辑
// 初始化图片数据
- (void) configImageData
{
    //初始化图片数组
    imageArray = [NSMutableArray array];
    [self addImageData];
}

// 加添加按钮数据
- (void) addImageData {
    SelectedPictureItem *pictureItem = [[SelectedPictureItem alloc] init];
    pictureItem.isCameraItem = YES;
    pictureItem.uploadImage = [UIImage imageNamed:@"bigadd.png"];
    //将加号加入到图片数组中
    [imageArray addObject:pictureItem];
}

// 初始化显示图片背景容器
- (UIScrollView *) configImagesView
{
    if (self.imageContainer != nil)
    {
        [self.imageContainer removeFromSuperview];
        self.imageContainer = nil;
    }
    self.imageContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 30, baseMeansTableView.frame.size.width - 20, 60)];
    [_imageContainer setContentSize:CGSizeMake(60 * imageArray.count, 100)];
    NSInteger index = 0;
    for (SelectedPictureItem *pictureItem in imageArray) {
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];//[[UIImageView alloc] initWithFrame:CGRectMake(index * 90, 10, 80, 80)];
        imageButton.frame = CGRectMake(index * 60, 5, 50, 50);
        [imageButton setImage:pictureItem.uploadImage forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
        imageButton.tag = index;
        [_imageContainer addSubview:imageButton];
        index ++;
    }
    
    return _imageContainer;
}

//点击按钮，弹出动作表单或警告视图
-(void)showImage:(UIButton *)button
{
    NSInteger buttonTag = button.tag;
    if (buttonTag < imageArray.count)
    {
        SelectedPictureItem *pictureItem = imageArray[buttonTag];
        if (pictureItem.isCameraItem)
        {
            [self showActionSheet];
        }
        else
        {
            [self showAlertToDeleteWithTag:buttonTag];
        }
    }
}

//显示动作表单
-(void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从手机中选择",nil];
    //设置动作表单类型
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    //射中动作表单显示位置
    [actionSheet showInView:self.view];
}

//显示删除警告视图方法
-(void)showAlertToDeleteWithTag:(NSInteger) buttonTag
{
    UIAlertView *alartView = [[UIAlertView alloc]initWithTitle:@"删除" message:@"您确定要删除吗?" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确定", nil];
    alartView.tag = buttonTag;
    [alartView show];
}

//警告视图确定按钮响应方法，点击确定删除所选按钮
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger index = alertView.tag;
    if (index < imageArray.count) {
        [imageArray removeObjectAtIndex:index];
        if (!((SelectedPictureItem *)[imageArray lastObject]).isCameraItem) {
            [self addImageData];
        }
        [baseMeansTableView reloadData];
    }
}

//点击动作表单按钮的响应方法
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //初始化
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            //设置可编辑
            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            //进入拍照界面
            [self presentViewController:picker animated:YES completion:^(void){}];
        }
        else
        {
            [self showHUDWithMsg: @"您的设备暂不支持拍照功能"];
            [self hideHUD];
        }
        
    }
    else if (buttonIndex == 1)
    {
        //从手机中选择
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        //设置选择后的图片可被编辑
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:^(void){}];
    }
}

#pragma mark - UIImagePickerControllerDelegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    SelectedPictureItem *pictureItem = [[SelectedPictureItem alloc] init];
    pictureItem.isCameraItem = NO;
    pictureItem.uploadImage = image;
    if (imageArray.count >= MAX_PHOTO_NUMBER)
    {
        SelectedPictureItem *lastPictureItem = [imageArray lastObject];
        if (lastPictureItem.isCameraItem)
        {
            [imageArray replaceObjectAtIndex:imageArray.count - 1 withObject:pictureItem];
        }
    }
    else
    {
        [imageArray insertObject:pictureItem atIndex:0];
    }
    [baseMeansTableView reloadData];
    // todo 不知道把图片放到沙盒做什么  要是除了展示还有其他用途你就再补上逻辑吧
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    //调用用户登录接口,获取机构id
//    loginInfo = 
//     = [_sharedClient getUserInfo];
//    NSLog(@"用户资料信息%@", userInfo);
//    
//    _userName = userInfo[@"UserName"];//用户名
//    _userPhone = userInfo[@"Mobile"]; //用户手机
//    _userAddress = userInfo[@"Address"]; //用户地址
//    _mainNote = userInfo[@"Note"]; //主营产品
//    _loginName = userInfo[@"LoginName"]; //登录名
    
}

//视图将要出现方法
-(void)viewDidAppear:(BOOL)animated
{
    
    //如果导航栏按钮文本为编辑，所有的控件不可输入，只起到显示数据作用
    if ([_editOrSaveBarButtonItem.title isEqualToString:@"编辑"])
    {
        _baseName.enabled = NO;
        _baseIntroduce.enabled = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ROW_BASEINTRODUCE)
    {
        return  82;
    }
    else if(indexPath.row == ROW_BASEPHOTO)
    {
        return 160;
    }
        
    return  44;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建cell标识符
    static NSString * cellIdentifier1 = @"cellLabelText";
    static NSString * cellIdentifier2 = @"cellLabelTextTwo";
    static NSString * cellIdentifier3 = @"cellLabelImageButton";
    
    UITableViewCell *cell;
    //创建重用cell
    if (indexPath.row == ROW_BASENAME)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier1];
        _baseName = UITextFieldWithTag(10);
        
    }
    else if(indexPath.row == ROW_BASEINTRODUCE)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier2];
        _baseIntroduce = UITextFieldWithTag(20);
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier3];
        //调用初始化图片容器方法，加载滚动视图
        UIScrollView *imageContainer = [self configImagesView];
        //将滚动视图加载到单元格中
        [cell.contentView addSubview:imageContainer];
    }
    
    return cell;
}

//设置单元格修改或禁止选中
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//点击编辑／保存按钮响应方法
- (IBAction)editAndSaveEventBarButtonItem:(UIBarButtonItem *)sender
{
    [_editOrSaveBarButtonItem setTitle:@"保存"];
    if ([_editOrSaveBarButtonItem.title isEqualToString:@"保存"])
    {
        _baseName.enabled = YES;
        _baseIntroduce.enabled = YES;
    }
    
}
@end
