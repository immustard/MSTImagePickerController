//
//  MSTImagePickerController.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>
#import "MSTImagePickerEnumeration.h"

@class MSTAssetModel;
@interface MSTImagePickerController : UINavigationController

/**
 构造器

 @param accessType 根据需要确定构造方法

 @return 实例
 */
- (instancetype)initWithAccessType:(MSTImagePickerAccessType)accessType;

/**
 是否多选，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsMutiSelected;

/**
 最大选择个数，只在多选(allowsMutiSelected)为 YES 时可用，默认为 9
 */
@property (assign, nonatomic) int maxSelectCount;

/**
 一行显示多少个，默认为 4
 */
@property (assign, nonatomic) int numsInRow;

/**
 是否有蒙版，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsMasking;

/**
 是否有选中动画，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsSelectedAnimation;

/**
 显示类型，默认为 Light
 */
@property (assign, nonatomic) MSTImagePickerStyle themeStyle;

/**
 图片分组类型，默认为 MSTImageGroupTypeNone
 */
@property (assign, nonatomic) MSTImageMomentGroupType photoMomentGroupType;

/**
 图片是否为降序排列，默认为 YES
 */
@property (assign, nonatomic) BOOL isPhotosDesc;

/**
 是否显示相册缩略图，默认为 YES
 */
@property (assign, nonatomic) BOOL isShowAlbumThumbnail;

/**
 是否显示相册包含图片个数，默认为 YES
 */
@property (assign, nonatomic) BOOL isShowAlbumNumber;

/**
 是否显示空相册，默认为 NO
 */
@property (assign, nonatomic) BOOL isShowEmptyAlbum;

/**
 是否只显示图片，默认为 NO
 */
@property (assign, nonatomic) BOOL isOnlyShowImages;

/**
 是否显示 Live Photo 图标，默认为 YES
 */
@property (assign, nonatomic) BOOL isShowLivePhotoIcon;

/**
 是否返回 Live Photo, 默认为 YES
 */
@property (assign, nonatomic) BOOL isCallBackLivePhoto;

/**
 第一个图标是否为相机，倒序为第一个，正序为最后一个
 默认为 YES
 */
@property (assign, nonatomic) BOOL isFirstCamera;

/**
 是否可以录制视频，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsMakingVideo;


/**
 最长视频时间，只有当 allowsMakingVideo 为 true 时可用，默认为 60
 */
@property (assign, nonatomic) NSTimeInterval videoMaximumDuration;

/**
 自定义相册名称，为空时保存到系统相册。不为空时，系统中没有该相册，则创建。
 */
@property (copy, nonatomic) NSString *customAlbumName;

/**
 相册界面 title ，默认为 『相册』
 */
@property (copy  , nonatomic) NSString *albumTitle;

/**
 相册占位缩略图
 */
@property (strong, nonatomic) UIImage *albumPlaceholderThumbnail;

/**
 展示时显示的颜色
 */
@property (strong, nonatomic) UIColor *pickerControllerTintColor;

/**
 照片选择时，未选择时图片
 */
@property (strong, nonatomic) UIImage *photoNormal;

/**
 照片选择时，已选择时图片
 */
@property (strong, nonatomic) UIImage *photoSelected;

/**
 MSTPhotoGridController 中，camera cell显示图片
 */
@property (strong, nonatomic) UIImage *cameraImage;






@property (strong, nonatomic) NSMutableArray<MSTAssetModel *> *selectedModels;

@end




















