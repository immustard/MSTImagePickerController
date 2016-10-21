//
//  MSTPhtoGridBaseCell.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/17.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoGridCell.h"
#import <PhotosUI/PHLivePhotoView.h>
#import "MSTPhotoConfiguration.h"

@interface MSTPhotoGridCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *liveBadgeImageView;
@property (strong, nonatomic) UIImageView *videoLengthBgView;
@property (strong, nonatomic) UILabel *videoLengthLabel;

@end

@implementation MSTPhotoGridCell
#pragma mark - Initialization Method
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self imageView];
    }
    return self;
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image targetSize:(CGSize)targetSize {
    self.imageView.image = image;

    self.imageView.frame = CGRectMake(0, 0, targetSize.width, targetSize.height);
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    self.liveBadgeImageView.hidden = YES;
    self.videoLengthBgView.hidden = YES;
    self.videoLengthLabel.text = @"";
    
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        //视频
        self.videoLengthBgView.hidden = NO;
        self.videoLengthLabel.text = [NSString stringWithFormat:@"%02d:%d", (int)asset.duration/60, (int)asset.duration%60];
    } else if ((asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) && config.isShowLivePhotoIcon) {
        //Live 图片
        self.liveBadgeImageView.hidden = NO;
    }
}

#pragma mark - Lazy Load
- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_imageView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _imageView;
}

- (UIImageView *)videoLengthBgView {
    if (!_videoLengthBgView) {
        self.videoLengthBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_grid_videoLength"]];
        _videoLengthBgView.contentMode = UIViewContentModeScaleToFill;
        _videoLengthBgView.clipsToBounds = YES;
        _videoLengthBgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_videoLengthBgView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-24];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _videoLengthBgView;
}

- (UILabel *)videoLengthLabel {
    if (!_videoLengthLabel) {
        self.videoLengthLabel = [UILabel new];
        _videoLengthLabel.font = [UIFont systemFontOfSize:13];
        _videoLengthLabel.textColor = [UIColor whiteColor];
        _videoLengthLabel.textAlignment = NSTextAlignmentRight;
        _videoLengthLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.videoLengthBgView addSubview:_videoLengthLabel];
        
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_videoLengthLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.videoLengthBgView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-5];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_videoLengthLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.videoLengthBgView attribute:NSLayoutAttributeCenterY multiplier:1 constant:3];
        [self.videoLengthBgView addConstraints:@[trailing, centerY]];
    }
    return _videoLengthLabel;
}

- (UIImageView *)liveBadgeImageView {
    if (!_liveBadgeImageView) {
        self.liveBadgeImageView = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
        _liveBadgeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveBadgeImageView.clipsToBounds = YES;
        _liveBadgeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_liveBadgeImageView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:30];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:30];
        [self.contentView addConstraints:@[leading, top, width, height]];
    }
    return _liveBadgeImageView;
}

@end



@interface MSTPhotoGridCameraCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation MSTPhotoGridCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.image = [UIImage imageNamed:@"icon_album_camera"];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_imageView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _imageView;
}

- (void)setCameraImage:(UIImage *)cameraImage {
    _cameraImage = cameraImage;
    
    self.imageView.image = cameraImage;
}

@end
