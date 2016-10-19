//
//  MSTPhotoPreviewCellDelegate.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSTPhotoPreviewCellDelegate <NSObject>

@optional

/**
 图片被点击一次
 */
- (void)photoHasBeenTapped;

@end
