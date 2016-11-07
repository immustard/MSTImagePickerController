//
//  MSTPickingModel.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/11/4.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAssetBaseModel.h"
#import <UIKit/UIKit.h>
#import <Photos/PHLivePhoto.h>

@interface MSTPickingModel : MSTAssetBaseModel

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) PHLivePhoto *livePhoto;

@property (strong, nonatomic) NSURL *videoURL;
@end
