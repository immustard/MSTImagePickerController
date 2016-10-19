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
    static MSTPhotoConfiguration *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MSTPhotoConfiguration alloc] init];
    });
    
    return instance;
}

@end
