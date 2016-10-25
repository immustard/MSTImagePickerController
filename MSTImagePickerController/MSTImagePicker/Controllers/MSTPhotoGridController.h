//
//  MSTPhotoGridController.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSTAlbumModel;

@interface MSTPhotoGridController : UICollectionViewController

/**
 相册信息, album information
 */
@property (strong, nonatomic) MSTAlbumModel *album;

/**
 添加 flowLayout

 @param num 一行有几个cell, the number of cells in one line

 */
+ (UICollectionViewFlowLayout *)flowLayoutWithNumInALine:(int)num;

@end
