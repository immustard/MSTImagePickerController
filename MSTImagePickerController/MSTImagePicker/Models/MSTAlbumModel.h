//
//  MSTAlbumModel.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>

@interface MSTAlbumModel : NSObject

/**
 相册名
 */
@property (copy  , nonatomic) NSString *albumName;

/**
 图片个数
 */
@property (assign, nonatomic, readonly) NSUInteger count;

/**
 相册内容
 */
@property (strong, nonatomic) PHFetchResult *content;

@end
