//
//  MSTAssetBaseModel.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/11/4.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSTAssetModelMediaType) {
    MSTAssetModelMediaTypeImage,
    MSTAssetModelMediaTypeLivePhoto,
    MSTAssetModelMediaTypeGIF,
    MSTAssetModelMediaTypeVideo,
    MSTAssetModelMediaTypeAudio,
    MSTAssetModelMediaTypeUnkown
};

@interface MSTAssetBaseModel : NSObject

@property (copy, nonatomic) NSString *identifier;

@property (assign, nonatomic) MSTAssetModelMediaType type;

//只有当 type 为 video 时有值
@property (assign, nonatomic) NSTimeInterval videoDuration;

@end
