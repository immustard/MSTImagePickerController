//
//  MSTVideoPreviewController.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/11/2.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MSTVideoPreviewController : AVPlayerViewController

- (instancetype)initWithAsset:(PHAsset *)asset;
- (instancetype)initWithURL:(NSURL *)url;
@end
