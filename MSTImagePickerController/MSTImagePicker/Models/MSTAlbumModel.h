//
//  MSTAlbumModel.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>
#import "MSTAssetModel.h"

@interface MSTAlbumModel : NSObject

/**
 相册名
 */
@property (copy  , nonatomic) NSString *albumName;

/**
 是否是『相机胶卷』
 */
@property (assign, nonatomic) BOOL isCameraRoll;

/**
 图片个数
 */
@property (assign, nonatomic, readonly) NSUInteger count;

/**
 相册内容
 */
@property (strong, nonatomic) PHFetchResult *content;

@property (strong, nonatomic) NSArray <MSTAssetModel *>*models;

@end
