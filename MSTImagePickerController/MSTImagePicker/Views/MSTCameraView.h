//
//  MSTCameraView.h
//  MSTImagePickerController
//
//  Created by 张宇豪 on 2017/5/2.
//  Copyright © 2017年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTCameraView : UIView

- (void)setPreviewLayerFrame:(CGRect)frame;

- (void)startSession;

- (void)stopSession;

@end
