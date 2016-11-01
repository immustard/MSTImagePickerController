//
//  MSTPhotoPreviewController.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSTPhotoPreviewControllerDelegate <NSObject>

- (void)photoPreviewDisappearIsFullImage:(BOOL)isFullImage;

@end

@class MSTAlbumModel, MSTMoment;
@interface MSTPhotoPreviewController : UIViewController

@property (weak, nonatomic) id<MSTPhotoPreviewControllerDelegate> delegate;

/**
 配置 preview 界面

 @param album     具体的相册信息   specific album information
 @param item      选中的位置       where didSelected
 */
- (void)didSelectedWithAlbum:(MSTAlbumModel *)album item:(NSInteger)item;

@end
