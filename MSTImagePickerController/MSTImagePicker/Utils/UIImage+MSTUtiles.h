//
//  UIImage+Utiles.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MSTUtiles)

/**
 调整图片方向
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/**
 获取图片压缩的目标尺寸
 */
+(CGSize) retriveScaleDstSize:(CGSize) srcSize;

/**
 修改图片尺寸

 @param newSize 新的尺寸

 */
- (UIImage*)resizeImageWithNewSize:(CGSize)newSize;

- (UIImage*)scaleImageWithMaxWidth:(CGFloat)maxWidth;

@end
