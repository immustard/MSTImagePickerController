//
//  MSTPhotoPreviewCell.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSTPhotoPreviewCellDelegate.h"

#define kLightStyleBGColor [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00]

@class MSTAssetModel;
@interface MSTPhotoPreviewImageCell : UICollectionViewCell

@property (strong, nonatomic) MSTAssetModel *model;

@property (weak, nonatomic) id<MSTPhotoPreviewCellDelegate> delegate;

/**
 已经显示到了那个cell
 */
- (void)didDisplayed;

- (void)recoverSubviews;

@end
