//
//  MSTPhotoManager.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>
#import "MSTMoment.h"

@class MSTAlbumModel;
@interface MSTPhotoManager : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

/**
 读取『相机胶卷』的信息
 
 @param isDesc          是否为倒序
 @param isOnlyShowImage 是否只显示图片
 @param completionBlock 返回数组<MSTAlbumModel>
 */
- (void)loadCameraRollInfoisDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void(^)(MSTAlbumModel *result)) completionBlock;

/**
 读取所有相册的信息

 @param isShowEmpty     是否显示空相册
 @param isDesc          是否为倒序
 @param isOnlyShowImage 是否只显示图片
 @param completionBlock 返回数组<MSTAlbumModel>
 */
- (void)loadAlbumInfoIsShowEmpty:(BOOL)isShowEmpty isDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void(^)(NSArray *albumModelArray)) completionBlock;

/**
 根据时间分组排序

 @param momentType  分组类型
 @param fetchResult 传入数据

 @return 分组结果
 */
- (NSArray<MSTMoment *> *)sortByMomentType:(MSTImageMomentGroupType)momentType assets:(PHFetchResult *)fetchResult;


/**
 读取预览图片，宽度默认为

 @param asset           图片内容
 @param isHighQuality   是否是高质量，为 YES 时，scale 为设备屏幕的 scale， NO 时 scale 为 0.1
 @param completionBlock 回调
 */
- (void)getPreviewImageFromPHAsset:(PHAsset *)asset isHighQuality:(BOOL)isHighQuality completionBlock:(void(^)(UIImage *result, NSDictionary *info, BOOL isDegraded))completionBlock;

- (void)getLivePhotoFromPHAsset:(PHAsset *)asset completionBlock:(void(^)(PHLivePhoto *livePhoto))completionBlock;

/** 读取原始图片 */
- (void)getOriginImageFromPHAsset:(PHAsset *)asset comletionBlock:(void(^)(UIImage *result))completionBlock;

@end
