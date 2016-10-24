//
//  MSTImagePickerEnumeration.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/24.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#ifndef MSTImagePickerEnumeration_h
#define MSTImagePickerEnumeration_h

typedef NS_ENUM(NSUInteger, MSTImagePickerAccessType) {
    MSTImagePickerAccessTypePhotosWithoutAlbums,        //无相册界面，但直接进入相册胶卷
    MSTImagePickerAccessTypePhotosWithAlbums,           //有相册界面，但直接进入相册胶卷
    MSTImagePickerAccessTypeAlbums                      //直接进入相册界面
};

typedef NS_ENUM(NSUInteger, MSTImagePickerSourceType) {
    MSTImagePickerSourceTypePhoto,              //图片
    MSTImagePickerSourceTypeCamera,             //相机
    MSTImagePickerSourceTypeSound               //声音
};

typedef NS_ENUM(NSUInteger, MSTAuthorizationStatus) {
    MSTAuthorizationStatusNotDetermined,        //未知
    MSTAuthorizationStatusRestricted,           //受限制
    MSTAuthorizationStatusDenied,               //拒绝
    MSTAuthorizationStatusAuthorized            //授权
};

typedef NS_ENUM(NSUInteger, MSTImageMomentGroupType) {
    MSTImageMomentGroupTypeNone,          //无分组
    MSTImageMomentGroupTypeYear,          //年
    MSTImageMomentGroupTypeMonth,         //月
    MSTImageMomentGroupTypeDay            //日
};

typedef NS_ENUM(NSUInteger, MSTImagePickerStyle) {
    MSTImagePickerStyleLight,       //浅色
    MSTImagePickerStyleDark         //深色
};

#endif /* MSTImagePickerEnumeration_h */
