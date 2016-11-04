//
//  MSTAssetModel.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/25.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAssetBaseModel.h"
#import <Photos/Photos.h>

@interface MSTAssetModel : MSTAssetBaseModel

@property (strong, nonatomic) PHAsset *asset;

@property (assign, nonatomic, getter=isSelected) BOOL selected;

+ (instancetype)modelWithAsset:(PHAsset *)asset;

@end
