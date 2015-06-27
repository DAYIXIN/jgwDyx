//
//  SelectedPictureItem.h
//  daYiXin
//
//  Created by JGW on 15/6/19.
//  Copyright (c) 2015年 JGW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectedPictureItem : NSObject

@property (nonatomic, strong) UIImage *uploadImage;//图片信息
@property (nonatomic, assign) NSInteger upLoadStatus;//1 - 没上传 2-上传成功 3- 上传失败 4 - 上传中
@property (nonatomic, assign) BOOL isCameraItem;//判断是否是相机拍摄


@end
