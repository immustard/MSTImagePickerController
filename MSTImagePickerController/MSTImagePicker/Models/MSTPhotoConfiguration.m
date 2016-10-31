//
//  MSTPhotoConfiguration.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoConfiguration.h"

@implementation MSTPhotoConfiguration

+ (instancetype)defaultConfiguration {
    static MSTPhotoConfiguration *config = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[MSTPhotoConfiguration alloc] init];
        
        config.allowsMutiSelected = YES;
        config.maxSelectCount = 9;
        config.numsInRow = 4;
        config.allowsMasking = YES;
        config.allowsSelectedAnimation = YES;
        config.themeStyle = MSTImagePickerStyleDark;
        config.photoMomentGroupType = MSTImageMomentGroupTypeNone;
        config.isPhotosDesc = YES;
        config.isShowAlbumThumbnail = YES;
        config.isShowAlbumNumber = YES;
        config.isShowEmptyAlbum = NO;
        config.isOnlyShowImages = NO;
        config.isShowLivePhotoIcon = YES;
        config.isCallBackLivePhoto = YES;
        config.isFirstCamera = YES;
        config.allowsMakingVideo = YES;
        config.videoMaximumDuration = 60.f;
        config.allowsPickGIF = YES;
    });
    
    return config;
}

@end
