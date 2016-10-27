//
//  MSTAlbumListCell.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAlbumListCell.h"
#import "MSTAlbumModel.h"
#import "MSTPhotoConfiguration.h"

@interface MSTAlbumListCell ()

@property (strong, nonatomic) UIImageView *behindImageView;
@property (strong, nonatomic) UIImageView *middleImageView;
@property (strong, nonatomic) UIImageView *frontImageView;

@end

@implementation MSTAlbumListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    MSTAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuserIdentifier];
    
    if (!cell) {
        cell = [[MSTAlbumListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAlbumCellReuserIdentifier];
        [cell mp_setupSubviews];
    }
    
    return cell;
}

#pragma mark - Setter
- (void)setAlbumModel:(MSTAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    //根据 model 进行设置     config with models
    [self mp_setupInfo];
}

#pragma mark - Lazy Load
- (UIImageView *)frontImageView {
    if (!_frontImageView) {
        self.frontImageView = [UIImageView new];
        _frontImageView.contentMode = UIViewContentModeScaleAspectFill;
        _frontImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _frontImageView.clipsToBounds = YES;
        [self.contentView addSubview:_frontImageView];
        [self.contentView addConstraints:[self mp_addLayoutContraints:_frontImageView]];
    }
    return _frontImageView;
}

- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        self.middleImageView = [UIImageView new];
        _middleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _middleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _middleImageView.clipsToBounds = YES;
        [self.contentView addSubview:_middleImageView];
        [self.contentView addConstraints:[self mp_addLayoutContraints:_middleImageView]];
    }
    return _middleImageView;
}

- (UIImageView *)behindImageView {
    if (!_behindImageView) {
        self.behindImageView = [UIImageView new];
        _behindImageView.contentMode = UIViewContentModeScaleAspectFill;
        _behindImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _behindImageView.clipsToBounds = YES;
        [self.contentView addSubview:_behindImageView];
        [self.contentView addConstraints:[self mp_addLayoutContraints:_behindImageView]];
    }
    return _behindImageView;
}

#pragma mark - Instance Methods
- (void)mp_setupInfo {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    //相册名
    self.textLabel.text = _albumModel.albumName;
    
    //照片个数
    if (config.isShowAlbumNumber)
        self.detailTextLabel.text = [NSString stringWithFormat:@"(%zd)", _albumModel.count];
    
    //缩略图
    _behindImageView.image = nil;
    _middleImageView.image = nil;
    _frontImageView.image = nil;
    self.imageView.image = nil;
    
    if (config.isShowAlbumThumbnail) {
        CGSize itemSize = CGSizeMake(50.f, 65.f);
        
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.f, 0.f, itemSize.width, itemSize.height);
        [self.imageView.image drawInRect:imageRect];
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (_albumModel.count) {
            //读取缩略图
            __block NSInteger fetchImageIndex = config.isPhotosDesc ? 0 : _albumModel.count-1;
            
            NSMutableArray *thumbnails = [NSMutableArray array];
            for (int i = 0; i < MIN(_albumModel.count, 3); i++) {
                [[PHCachingImageManager defaultManager] requestImageForAsset:_albumModel.content[fetchImageIndex] targetSize:CGSizeMake(80*2.f, 80*2.f) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    if (result) [thumbnails addObject:result];

                    if (i == MIN(_albumModel.count, 3) - 1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (int j = 0; j < MIN(_albumModel.count, 3); j++) {
                                switch (j) {
                                    case 0:
                                        if (thumbnails.count) self.frontImageView.image = thumbnails[j];
                                        break;
                                    case 1:
                                        if (thumbnails.count > 1) self.middleImageView.image = thumbnails[j];
                                        break;
                                    case 2:
                                        if (thumbnails.count > 2) self.behindImageView.image = thumbnails[j];
                                        break;
                                    default:
                                        break;
                                }
                            }
                        });
                    }
                }];
                config.isPhotosDesc ? fetchImageIndex++ : fetchImageIndex--;
            }
        } else {
            if (self.placeholderThumbnail)
                self.frontImageView.image = self.placeholderThumbnail;
            else
                self.frontImageView.image = [UIImage imageNamed:@"icon_album_placeholder"];
        }
    }
}

- (void)mp_setupSubviews {
    [self behindImageView];
    [self middleImageView];
    [self frontImageView];
}

/**
 根据imageView添加约束

 @param imageView 需要添加的是哪个 imageView
 */
- (NSArray *)mp_addLayoutContraints:(UIImageView *)imageView {
    int tag = 0;
    if (imageView == _frontImageView) tag = 0;
    if (imageView == _middleImageView) tag = 1;
    if (imageView == _behindImageView) tag = 2;
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:7+tag*2];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(7+tag*6)];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:17-tag*2];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    return @[leading, bottom, top, width];
}

@end
