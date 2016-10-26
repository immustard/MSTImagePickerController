//
//  MSTPickAssetModel.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/25.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPickAssetModel.h"

@implementation MSTPickAssetModel

+ (instancetype)MSTPickAssetModelWithAsset:(PHAsset *)asset {
    MSTPickAssetModel *model = [MSTPickAssetModel new];
    
    model.asset = asset;
    
    return model;
}

- (NSString *)identifier {
    return self.asset.localIdentifier;
}

- (MSTPickAssetModelMediaType)type {
    if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return MSTPickAssetModelMediaTypeLivePhoto;
    
    if (self.asset.mediaType == PHAssetMediaTypeImage) return MSTPickAssetModelMediaTypeImage;
    
    if (self.asset.mediaType == PHAssetMediaTypeVideo) return MSTPickAssetModelMediaTypeVideo;
    
    if (self.asset.mediaType == PHAssetMediaTypeAudio) return MSTPickAssetModelMediaTypeAudio;
    
    return MSTPickAssetModelMediaTypeUnkown;
}

- (NSTimeInterval)videoDuration {
    if (self.type == MSTPickAssetModelMediaTypeVideo) return self.asset.duration;
    
    return 0.f;
}
@end
