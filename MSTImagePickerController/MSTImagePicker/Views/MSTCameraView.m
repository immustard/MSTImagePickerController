//
//  MSTCameraView.m
//  MSTImagePickerController
//
//  Created by 张宇豪 on 2017/5/2.
//  Copyright © 2017年 Mustard. All rights reserved.
//

#import "MSTCameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface MSTCameraView ()
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;

/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;

/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@end

@implementation MSTCameraView

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        [self mp_initAVCaptureSession];
    }
    return self;
}

- (void)setPreviewLayerFrame:(CGRect)frame {
    self.previewLayer.frame = frame;
}

- (void)startSession {
    if (self.session) 
        [self.session startRunning];
}

- (void)stopSession {
    if (self.session)
        [self.session stopRunning];
}

- (void)mp_initAVCaptureSession {
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error)
        NSLog(@"%@",error);
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput])
        [self.session addInput:self.videoInput];
    
    if ([self.session canAddOutput:self.stillImageOutput])
        [self.session addOutput:self.stillImageOutput];
    
    //初始化预览图层
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:self.previewLayer];
}

#pragma mark - Lazy Load
- (AVCaptureSession *)session {
    if (!_session) {
        self.session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

@end























