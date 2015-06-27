//
//  AddProductMeansViewController.m
//  daYiXin
//
//  Created by JGW on 15/5/26.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import "AddProductMeansViewController.h"
#import "JGWClient.h"
#import "CommonConstant.h"
#import "SelectedPictureItem.h"

//宏定义，代表单元格项的索引值
#define ROW_NAME 0  //产品名称
#define ROW_STYLE 1 //产品类型
#define ROW_CODE 2 //产品编号
#define ROW_INTRODUCE 3 //产品介绍
//#define ROW_PHOTO 0 //产品照片//@interface SelectedPictureItem : NSObject
//@property (nonatomic, strong) UIImage *uploadImage;//图片信息
//@property (nonatomic, assign) NSInteger upLoadStatus;//1 - 没上传 2-上传成功 3- 上传失败 4 - 上传中
//@property (nonatomic, assign) BOOL isCameraItem;
//@end
//
//@implementation SelectedPictureItem
//
//
//
//@end


//#define ROW_SHOW 1 //预览
#define MAX_PHOTO_NUMBER 5


@interface AddProductMeansViewController ()<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    NSString *filePath;
    NSMutableArray *imageArray;
    NSMutableArray *buttonArray;
}
//定义一个滚动视图
@property (nonatomic, strong) UIScrollView *imageContainer;
@end

@implementation AddProductMeansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //准备数据,单元格标签title
    cellTitles = @[@"产品名称:",@"产品类型:",@"产品编号:",@"产品介绍:"];
      cellKeys = @[@"ProName",@"ProStyle",@"ProCode",@"ProIntroduce"];
    //单元格文本框占位符
    cellPlaceholders = @[@"请输入产品名称",@"请输入产品类型",@"请输入产品编号",@"请输入产品介绍"];
    if (!self.editingProID)
    {
        self.title = @"产品添加";
    }
    else
    {
        self.title = @"产品编辑";
    }
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
- (void) addImageData
{
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
    self.imageContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 30, proMeansTableView.frame.size.width - 20, 60)];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
//返回分区数
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//返回分区中的单元格数
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (section == 0)
        {
            return 4;
        }
        else
        {
            return 1;
        }

}

//返回每个单元格的高度
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == proMeansTableView)
    {
        if (indexPath.section == 1)
        {
            return  140;
        }
    }
       return 44;
}

//给单元格添加数据
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //定义单元格标签标题标识符
    static NSString *cellIdentifier = @"cellLabelText";
    static NSString *cellIdentifier1 = @"cellLabelImageButton";
//    static NSString *cellIdentifier2 = @"cellImage";
    
    //定义表格视图单元格
    UITableViewCell *cell;
    switch (indexPath.section)
    {
            //第一分区数据
        case 0:
            //批次编码，生产人单元格
            if (indexPath.row == ROW_NAME || indexPath.row == ROW_STYLE || indexPath.row == ROW_CODE || indexPath.row == ROW_INTRODUCE)
            {
                //这里是根据ID来创建不同的Cell实例
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                //为单元格标签控件赋值
                UILabelWithTag(100).text = [cellTitles objectAtIndex: indexPath.row];
                
                //为单元格文本框控件添加占位符
                UITextField *textField = UITextFieldWithTag(200);
                textField.placeholder = [cellPlaceholders objectAtIndex:indexPath.row];
                textField.text = [proMeansDict objectForKey: [cellKeys objectAtIndex: indexPath.row]];
                //分别获取单元格文本框，产品名称，产品类型，产品编号，产品介绍
                if (indexPath.row == ROW_NAME)
                {
                    textField.tag = 10;
                    _proNameTextField = UITextFieldWithTag(10);
                }
                else if (indexPath.row == ROW_STYLE)
                {
                    textField.tag = 11;
                    _proStyleTextField = UITextFieldWithTag(11);
                    //设置产品类型文本框不可编辑
                    _proStyleTextField.enabled = NO;
                }
                else if (indexPath.row == ROW_CODE)
                {
                    textField.tag = 12;
                    _proCodeTextField = UITextFieldWithTag(12);
                }
                else
                {
                    textField.tag = 13;
                    _proIntroduceTextField = UITextFieldWithTag(13);
                }
                
            }
            break;
            
        case 1:
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
                
                //调用初始化图片容器方法，加载滚动视图
                UIScrollView *imageContainer = [self configImagesView];
                //将滚动视图加载到单元格中
                [cell.contentView addSubview:imageContainer];
//                UIButton *showImage = UIButtonWithTag(21);
//                //                    [cell.contentView addSubview:showImage];
//                //                    [cell bringSubviewToFront:showImage];
//                [showImage addTarget:self action:@selector(showImageView:) forControlEvents:UIControlEventTouchUpInside];
                
                 return cell;
            }
            
            break;
            
        default:
            break;
    }

    
    return cell;
}

//禁止单元格被选中
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果为第一分区的第一行，可以选中，其他单元格都不可选中
    if (indexPath.section == 0)
    {
        if (indexPath.row == ROW_STYLE)
        {
            return indexPath;
        }
    }
    return nil;
}

#pragma mark - myCustom
//-(void)showImageView:(UIButton *)button
//{
//    NSLog(@"hello world\n");
//    _showImageTableViewView.hidden = NO;
//}

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
    if (index < imageArray.count)
    {
        [imageArray removeObjectAtIndex:index];
        if (!((SelectedPictureItem *)[imageArray lastObject]).isCameraItem)
        {
            [self addImageData];
        }
        [proMeansTableView reloadData];
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
            sourceType = UIImagePickerControllerSourceTypeCamera;
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
    [proMeansTableView reloadData];
        // todo 不知道把图片放到沙盒做什么  要是除了展示还有其他用途你就再补上逻辑吧
     [self dismissViewControllerAnimated:YES completion:^(void){}];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

//对表格视图里行选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            NSLog(@"此行被选中\n");
        }
    }
    
}

//点击保存按钮，保存商品信息
- (IBAction)saveDataBarButtonItem:(UIBarButtonItem *)sender
{
    //判断产品名称是否输入
    if ([_proNameTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入产品名称" : nil];
        return;
    }
//    //判断产品类型是否输入
//    if ([_proStyleTextField.text length]<1)
//    {
//        [_commonUtils showMessageBox: @"请选择产品类型" : nil];
//        return;
//    }
    //判断产品编号是否输入
    if ([_proCodeTextField.text length]<1)
    {
        [_commonUtils showMessageBox: @"请输入产品编码" : nil];
        return;
    }
    //显示保存图标
    [self showHUDWithMsg: @"保存中"];
    [_sharedClient addProductInfoWithProductName:_proNameTextField.text andClassifyID:@"8eab5c74-887a-462e-ac34-e677ff7d4dd6&Token=2a1b75ce-103b-4070-b6bc-457745b5bcf8" andCategoryID:@"3c215597-1d2b-45af-84e3-36ebb33fb312" andPriceSell:@"2" andPriceOriginal:@"1" andStock:50 andLayer3UnitID:50 andThumbnail:nil];
    [self hideHUD];
    
    
    
//      //在编辑状态下，修改了内容之后，调用编辑批次接口
//    if (self.editingProID != nil)
//    {
//        [_sharedClient editProductBatchWithId:self.editingProID andProductBatchCode:_code andProductBatchContent:proBatchContent];
//        
//    }
    //隐藏图标
    [self hideHUD];
    //回到上级界面
    [self.navigationController popViewControllerAnimated:YES];
}
@end
