//
//  MSTPhotoPreviewCell.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>
#import "MSTPhotoPreviewCellDelegate.h"

@interface MSTPhotoPreviewImageCell : UICollectionViewCell

@property (strong, nonatomic) PHAsset *asset;

@property (weak, nonatomic) id<MSTPhotoPreviewCellDelegate> delegate;

@end
