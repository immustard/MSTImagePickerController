//
//  MSTPhotoPreviewCell.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoPreviewImageCell.h"
#import <PhotosUI/PhotosUI.h>
#import "MSTPhotoConfiguration.h"
#import "UIView+MSTUtils.h"
#import "MSTPhotoManager.h"
#import "MSTAssetModel.h"

@interface MSTPhotoPreviewImageCell ()<UIScrollViewDelegate> {
    BOOL _isLivePhoto;
}

@property (strong, nonatomic) UIScrollView *myScrollView;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView;

@property (strong, nonatomic) UIImageView *liveBadgeImageView;

@end

@implementation MSTPhotoPreviewImageCell
#pragma mark - Inintialization Method
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self mp_setupSubview];
    }
    return self;
}

#pragma mark - Lazy Load
- (UIScrollView *)myScrollView {
    if (!_myScrollView) {
        self.myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.mst_width - 20, self.mst_height)];
        _myScrollView.bouncesZoom = YES;
        _myScrollView.minimumZoomScale = 1.f;
        _myScrollView.maximumZoomScale = 2.5f;
        _myScrollView.multipleTouchEnabled = YES;
        _myScrollView.scrollsToTop = NO;
        _myScrollView.showsHorizontalScrollIndicator = NO;
        _myScrollView.showsVerticalScrollIndicator = NO;
        _myScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _myScrollView.delaysContentTouches = NO;

        _myScrollView.delegate = self;
        
        [self addSubview:_myScrollView];
    }
    return _myScrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        
        [self.myScrollView addSubview:_imageView];
    }
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        self.livePhotoView = [PHLivePhotoView new];
        _livePhotoView.clipsToBounds = YES;
        
        [self.myScrollView addSubview:_livePhotoView];
    }
    return _livePhotoView;
}


- (UIImageView *)liveBadgeImageView {
    if (!_liveBadgeImageView) {
        self.liveBadgeImageView = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
        _liveBadgeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveBadgeImageView.clipsToBounds = YES;
        _liveBadgeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _liveBadgeImageView.hidden = YES;
        [self.livePhotoView addSubview:_liveBadgeImageView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeLeading multiplier:1 constant:30];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeTop multiplier:1 constant:30];
        [self.livePhotoView addConstraints:@[leading, top, width, height]];
    }
    return _liveBadgeImageView;
}

#pragma mark - Setter
- (void)setModel:(MSTAssetModel *)model {
    _model = model;
    
    self.imageView.image = nil;
    self.livePhotoView.livePhoto = nil;
    self.liveBadgeImageView.hidden = YES;
    
    if (model.type == MSTAssetModelMediaTypeLivePhoto && [UIDevice currentDevice].systemVersion.floatValue >= 9.1 && [MSTPhotoConfiguration defaultConfiguration].isCallBackLivePhoto) {
        _isLivePhoto = YES;
        
        [[MSTPhotoManager defaultManager] getLivePhotoFromPHAsset:model.asset completionBlock:^(PHLivePhoto *livePhoto, BOOL isDegraded) {
            if (!isDegraded) {
                self.livePhotoView.livePhoto = livePhoto;
                if ([MSTPhotoConfiguration defaultConfiguration].isShowLivePhotoIcon)
                    self.liveBadgeImageView.hidden = NO;
                [self mp_resizeSubviews];
            }
        }];
    } else {
        _isLivePhoto = NO;
        
        [[MSTPhotoManager defaultManager] getPreviewImageFromPHAsset:model.asset isHighQuality:NO completionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
            self.imageView.image = result;
            [self mp_resizeSubviews];
        }];
    }
}

#pragma mark - Instance Methods
- (void)didDisplayed {
    if (!_isLivePhoto) {
        [[MSTPhotoManager defaultManager] getPreviewImageFromPHAsset:_model.asset isHighQuality:YES completionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
            if (!isDegraded) {
                self.imageView.image = result;
                [self mp_resizeSubviews];
            }
        }];
    }
}

- (void)recoverSubviews {
    [self.myScrollView setZoomScale:1.0 animated:NO];
    [self mp_resizeSubviews];
}

- (void)mp_setupSubview {
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    switch (config.themeStyle) {
        case MSTImagePickerStyleDark:
            self.myScrollView.backgroundColor = [UIColor blackColor];
            self.contentView.backgroundColor = [UIColor blackColor];
            break;
        case MSTImagePickerStyleLight:
            self.myScrollView.backgroundColor = kLightStyleBGColor;
            self.contentView.backgroundColor = kLightStyleBGColor;
            break;
        default:
            break;
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_singleTap:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

- (void)mp_resizeSubviews {
    if (!_isLivePhoto) {
        self.imageView.mst_origin = CGPointZero;
        self.imageView.mst_width = self.myScrollView.mst_width;
        
        UIImage *image = self.imageView.image;
        if (image.size.height / image.size.width > self.mst_height / self.myScrollView.mst_width) {
            _imageView.mst_height = floor(image.size.height / (image.size.width / self.myScrollView.mst_width));
        } else {
            CGFloat height = image.size.height / image.size.width * self.myScrollView.mst_width;
            if (height < 1 || isnan(height)) height = self.mst_height;
            height = floor(height);
            _imageView.mst_height = height;
            _imageView.mst_centerY = self.mst_height / 2;
        }
        
        if (_imageView.mst_height > self.mst_height && _imageView.mst_height - self.mst_height <= 1) {
            _imageView.mst_height = self.mst_height;
        }
        
        _myScrollView.contentSize = CGSizeMake(_myScrollView.mst_width, MAX(_imageView.mst_height, self.mst_height));
        [_myScrollView scrollRectToVisible:self.bounds animated:NO];
        _myScrollView.alwaysBounceVertical = _imageView.mst_height <= self.mst_height ? NO : YES;
    } else {
        self.livePhotoView.mst_origin = CGPointZero;
        self.livePhotoView.mst_width = self.myScrollView.mst_width;
        
        PHLivePhoto *photo = self.livePhotoView.livePhoto;
        if (photo.size.height / photo.size.width > self.mst_height / self.myScrollView.mst_width) {
            _livePhotoView.mst_height = floor(photo.size.height / (photo.size.width / self.myScrollView.mst_width));
        } else {
            CGFloat height = photo.size.height / photo.size.width * self.myScrollView.mst_width;
            if (height < 1 || isnan(height)) height = self.mst_height;
            height = floor(height);
            _livePhotoView.mst_height = height;
            _livePhotoView.mst_centerY = self.mst_height / 2;
        }
        
        if (_livePhotoView.mst_height > self.mst_height && _livePhotoView.mst_height - self.mst_height <= 1) {
            _livePhotoView.mst_height = self.mst_height;
        }
        
        _myScrollView.contentSize = CGSizeMake(_myScrollView.mst_width, MAX(_livePhotoView.mst_height, self.mst_height));
        [_myScrollView scrollRectToVisible:self.bounds animated:NO];
        _myScrollView.alwaysBounceHorizontal = _livePhotoView.mst_height <= self.mst_height ? NO : YES;
    }
}

- (void)mp_singleTap:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(photoHasBeenTapped)]) {
        [_delegate photoHasBeenTapped];
    }
}

- (void)mp_doubleTap:(UITapGestureRecognizer *)gesture {
    if (self.myScrollView.zoomScale > 1.f) {
        [_myScrollView setZoomScale:1.f animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:self.imageView];
        CGFloat newZoomScale = _myScrollView.maximumZoomScale;
        CGFloat xSize = self.frame.size.width / newZoomScale;
        CGFloat ySize = self.frame.size.height / newZoomScale;
        [_myScrollView zoomToRect:CGRectMake(touchPoint.x - xSize/2, touchPoint.y - ySize/2, xSize, ySize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    if (!_isLivePhoto) {
        self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    } else {
        self.livePhotoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (_isLivePhoto) {
        return self.livePhotoView;
    }
    return self.imageView;
}
@end
