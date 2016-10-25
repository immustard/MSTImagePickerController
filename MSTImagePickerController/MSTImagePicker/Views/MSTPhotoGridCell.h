//
//  MSTPhtoGridBaseCell.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/17.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Photos/Photos.h>

@protocol MSTPhotoGridCellDelegate <NSObject>

- (void)selectedButtonDidClicked:(BOOL)isSelected;

@end

@interface MSTPhotoGridCell : UICollectionViewCell

@property (strong, nonatomic) PHAsset *asset;
@property (weak, nonatomic) id<MSTPhotoGridCellDelegate> delegate;

- (void)setImage:(UIImage *)image targetSize:(CGSize)targetSize;

@end




@interface MSTPhotoGridCameraCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *cameraImage;

@end
