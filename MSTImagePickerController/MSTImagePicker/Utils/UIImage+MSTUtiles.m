//
//  UIImage+Utiles.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "UIImage+MSTUtiles.h"

@implementation UIImage (MSTUtiles)

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(CGSize) retriveScaleDstSize:(CGSize)srcSize {
    float scale = 0;
    if (!scale) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    if (srcSize.height > srcSize.width) {
        //限制宽度
        float limitWidth = 640;
        if(srcSize.width > limitWidth)
        {
            return CGSizeMake(limitWidth, srcSize.height * limitWidth / srcSize.width);
        }
        return srcSize;
    }else {
        //限制高度
        float limitHeight = 640;
        if (srcSize.height > limitHeight)
        {
            return CGSizeMake(srcSize.width * limitHeight / srcSize.height, limitHeight);
        }
        return srcSize;
    }
}

- (UIImage*)resizeImageWithNewSize:(CGSize)newSize {
    CGFloat newWidth = newSize.width;
    CGFloat newHeight = newSize.height;
    // Resize image if needed.
    float width  = self.size.width;
    float height = self.size.height;
    // fail safe
    if (width == 0 || height == 0)
        return self;
    
    //float scale;
    
    if (width != newWidth || height != newHeight) {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        
        UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //NSData *jpeg = UIImageJPEGRepresentation(image, 0.8);
        return resized;
    }
    return self;
}

- (UIImage *)scaleImageWithMaxWidth:(CGFloat)maxWidth {
    float whratio = self.size.width / self.size.height;
    
    if(whratio > 1.0f) {
        CGFloat width = maxWidth;
        if(self.size.width < width)
            return self;
        
        CGFloat height = self.size.height * width / self.size.width;
        CGSize sizeNew = CGSizeMake(width, height);
        
        UIGraphicsBeginImageContext(sizeNew);
        [self drawInRect:CGRectMake(0, 0, sizeNew.width, sizeNew.height)];
        UIImage* sImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return sImg;
    } else {
        CGFloat height = maxWidth;
        if(self.size.height < height)
            return self;
        
        CGFloat width = self.size.width * height / self.size.height;
        CGSize sizeNew = CGSizeMake(width, height);
        
        UIGraphicsBeginImageContext(sizeNew);
        [self drawInRect:CGRectMake(0, 0, sizeNew.width, sizeNew.height)];
        UIImage* sImg = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return sImg;
    }
}
@end
