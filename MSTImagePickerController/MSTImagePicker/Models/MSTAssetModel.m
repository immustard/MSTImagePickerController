//
//  MSTAssetModel.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/25.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAssetModel.h"

@implementation MSTAssetModel

+ (instancetype)MSTAssetModelWithAsset:(PHAsset *)asset {
    MSTAssetModel *model = [MSTAssetModel new];
    
    model.asset = asset;
    
    return model;
}

- (NSString *)identifier {
    return self.asset.localIdentifier;
}

- (MSTAssetModelMediaType)type {
    if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return MSTAssetModelMediaTypeLivePhoto;
    
    if (self.asset.mediaType == PHAssetMediaTypeImage) return MSTAssetModelMediaTypeImage;
    
    if (self.asset.mediaType == PHAssetMediaTypeVideo) return MSTAssetModelMediaTypeVideo;
    
    if (self.asset.mediaType == PHAssetMediaTypeAudio) return MSTAssetModelMediaTypeAudio;
    
    return MSTAssetModelMediaTypeUnkown;
}

- (NSTimeInterval)videoDuration {
    if (self.type == MSTAssetModelMediaTypeVideo) return self.asset.duration;
    
    return 0.f;
}
@end
