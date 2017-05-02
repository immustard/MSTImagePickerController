//
//  MSTPhtoGridBaseCell.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/17.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>

@class MSTAssetModel, MSTCameraView;

@protocol MSTPhotoGridCellDelegate <NSObject>

- (BOOL)gridCellSelectedButtonDidClicked:(BOOL)isSelected selectedAsset:(MSTAssetModel *)asset;

@end

@interface MSTPhotoGridCell : UICollectionViewCell

@property (strong, nonatomic) MSTAssetModel *asset;
@property (weak, nonatomic) id<MSTPhotoGridCellDelegate> delegate;

@end




@interface MSTPhotoGridCameraCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *cameraImage;

@property (strong, nonatomic) MSTCameraView *cameraView;

@end
