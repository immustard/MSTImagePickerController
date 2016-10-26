//
//  MSTPickAssetModel.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/25.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, MSTPickAssetModelMediaType) {
    MSTPickAssetModelMediaTypeImage,
    MSTPickAssetModelMediaTypeLivePhoto,
    MSTPickAssetModelMediaTypeGIF,
    MSTPickAssetModelMediaTypeVideo,
    MSTPickAssetModelMediaTypeAudio,
    MSTPickAssetModelMediaTypeUnkown
};

@interface MSTPickAssetModel : NSObject

@property (copy, nonatomic, readonly) NSString *identifier;

@property (assign, nonatomic, readonly) MSTPickAssetModelMediaType type;

//只有当 type 为 video 时有值
@property (assign, nonatomic, readonly) NSTimeInterval videoDuration;

@property (strong, nonatomic) PHAsset *asset;

@property (assign, nonatomic) BOOL isSelected;

+ (instancetype)MSTPickAssetModelWithAsset:(PHAsset *)asset;
@end
