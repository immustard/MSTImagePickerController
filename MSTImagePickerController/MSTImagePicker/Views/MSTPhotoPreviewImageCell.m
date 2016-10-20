//
//  MSTPhotoPreviewCell.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoPreviewImageCell.h"
#import "UIView+MSTUtils.h"
#import "MSTPhotoManager.h"

@interface MSTPhotoPreviewImageCell ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *myScrollView;

@property (strong, nonatomic) UIImageView *imageView;

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
        self.myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.width - 20, self.height)];
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
        _imageView.backgroundColor = [UIColor whiteColor];
        
        [self.myScrollView addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - Setter
- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    [[MSTPhotoManager sharedInstance] getPreviewImageFromPHAsset:_asset isHighQuality:NO comletionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
        self.imageView.image = result;
        [self mp_resizeSubviews];
    }];
}

#pragma mark - Instance Methods
- (void)didDisplayed {
    [[MSTPhotoManager sharedInstance] getPreviewImageFromPHAsset:_asset isHighQuality:YES comletionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
        if (!isDegraded) {
            self.imageView.image = result;
            [self mp_resizeSubviews];
        }
    }];
}

- (void)mp_setupSubview {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_singleTap:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

- (void)mp_resizeSubviews {
    self.imageView.origin = CGPointZero;
    self.imageView.width = self.myScrollView.width;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.height / self.myScrollView.width) {
        _imageView.height = floor(image.size.height / (image.size.width / self.myScrollView.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.myScrollView.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        _imageView.height = height;
        _imageView.centerY = self.height / 2;
    }
    
    if (_imageView.height > self.height && _imageView.height - self.height <= 1) {
        _imageView.height = self.height;
    }
    
    _myScrollView.contentSize = CGSizeMake(_myScrollView.width, MAX(_imageView.height, self.height));
    [_myScrollView scrollRectToVisible:self.bounds animated:NO];
    _myScrollView.alwaysBounceVertical = _imageView.height <= self.height ? NO : YES;
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
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
@end
