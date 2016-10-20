//
//  MSTPhotoPreviewController.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSTAlbumModel, MSTMoment;
@interface MSTPhotoPreviewController : UIViewController

/**
 配置 preview 界面

 @param album     具体的相册信息   specific album information
 @param indexPath 选中的位置       where didSelected
 */
- (void)didSelectedWithAlbum:(MSTAlbumModel *)album indexPath:(NSIndexPath *)indexPath;

@end
