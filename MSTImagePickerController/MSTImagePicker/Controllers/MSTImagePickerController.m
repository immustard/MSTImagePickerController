//
//  MSTImagePickerController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTImagePickerController.h"
#import "MSTPhotoConfiguration.h"
#import "MSTAlbumListController.h"
#import "MSTPhotoGridController.h"
#import "UIViewController+MSTUtils.h"
#import "MSTPhotoManager.h"
#import "MSTAlbumModel.h"

@interface MSTImagePickerController ()

@property (strong, nonatomic) MSTPhotoConfiguration *config;

@property (assign, nonatomic) MSTImagePickerAccessType accessType;

@property (strong, nonatomic) MSTAlbumListController *albumListController;
@property (strong, nonatomic) MSTPhotoGridController *photoGridController;

@end

@implementation MSTImagePickerController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setToolbarHidden:NO animated:NO];
    
    [self mp_setupNavigationBar];
    [self mp_checkAuthorizationStatus];
}

#pragma mark - Initialization Methods
- (instancetype)initWithAccessType:(MSTImagePickerAccessType)accessType{
    if (self = [super init]) {
        self.accessType = accessType;
        self.albumTitle = NSLocalizedStringFromTable(@"str_photos", @"MSTImagePicker", @"相册");
    }
    return self;
}

#pragma mark - Instance Methods
/**
 检查授权访问状态
 */
- (void)mp_checkAuthorizationStatus {
    [MSTPhotoManager checkAuthorizationStatusWithSourceType:MSTImagePickerSourceTypePhoto callBack:^(MSTImagePickerSourceType sourceType, MSTAuthorizationStatus status) {
        switch (status) {
            case MSTAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case MSTAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
            case MSTAuthorizationStatusDenied:{
                NSLog(@"PHAuthorizationStatusDenied");
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTable(@"str_allow_photoLibrary", @"MSTImagePicker", @"允许访问") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"str_confirm", @"MSTImagePicker", @"确认") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
                
                break;
            }
            case MSTAuthorizationStatusAuthorized:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (_accessType) {
                        case MSTImagePickerAccessTypeAlbums: {
                            [self setViewControllers:@[self.albumListController]];
                        }
                            break;
                        case MSTImagePickerAccessTypePhotosWithAlbums: {
                            [self setViewControllers:@[self.albumListController, self.photoGridController]];
                        }
                            break;
                        case MSTImagePickerAccessTypePhotosWithoutAlbums: {
                            [self.photoGridController addNavigationLeftCancelBtn];
                            [self setViewControllers:@[self.photoGridController] animated:YES];
                        }
                            break;
                    }
                    NSLog(@"PHAuthorizationStatusAuthorized");
                });
                break;
            }
            default:
                break;
        }
    }];
}

- (void)mp_setupNavigationBar {
    switch (self.config.themeStyle) {
        case MSTImagePickerStyleLight:
            self.navigationBar.barStyle = UIBarStyleDefault;
            self.navigationBar.translucent = YES;
            break;
        case MSTImagePickerStyleDark:
            self.navigationBar.barStyle = UIBarStyleBlack;
            self.navigationBar.translucent = YES;
            self.navigationBar.tintColor = [UIColor whiteColor];
            break;
    }
}

#pragma mark - Lazy Load
- (MSTPhotoConfiguration *)config {
    if (!_config) {
        self.config = [MSTPhotoConfiguration defaultConfiguration];
    }
    return _config;
}

- (MSTAlbumListController *)albumListController{
    if (!_albumListController) {
        self.albumListController = [[MSTAlbumListController alloc] init];
        [_albumListController addNavigationLeftCancelBtn];
    }
    return _albumListController;
}

- (MSTPhotoGridController *)photoGridController{
    if (!_photoGridController) {
        self.photoGridController = [[MSTPhotoGridController alloc] initWithCollectionViewLayout:[MSTPhotoGridController flowLayoutWithNumInALine:self.config.numsInRow]];
        [[MSTPhotoManager alloc] loadCameraRollInfoisDesc:_config.isPhotosDesc isOnlyShowImage:self.config.isOnlyShowImages CompletionBlock:^(MSTAlbumModel *result) {
            _photoGridController.album = result;
        }];
    }
    return _photoGridController;
}

#pragma mark - Setter
- (void)setAllowsMutiSelected:(BOOL)allowsMutiSelected {
    self.config.allowsMutiSelected = allowsMutiSelected;
}

- (void)setMaxSelectCount:(int)maxSelectCount {
    self.config.maxSelectCount = maxSelectCount;
}

- (void)setNumsInRow:(int)numsInRow {
    self.config.numsInRow = numsInRow;
}

- (void)setAllowsMasking:(BOOL)allowsMasking {
    self.config.allowsMasking = allowsMasking;
}

- (void)setAllowsSelectedAnimation:(BOOL)allowsSelectedAnimation {
    self.config.allowsSelectedAnimation = allowsSelectedAnimation;
}

- (void)setThemeStyle:(MSTImagePickerStyle)themeStyle {
    self.config.themeStyle = themeStyle;
}

- (void)setPhotoMomentGroupType:(MSTImageMomentGroupType)photoMomentGroupType {
    self.config.photoMomentGroupType = photoMomentGroupType;
}

- (void)setIsPhotosDesc:(BOOL)isPhotosDesc {
    self.config.isPhotosDesc = isPhotosDesc;
}

- (void)setIsShowAlbumThumbnail:(BOOL)isShowAlbumThumbnail {
    self.config.isShowAlbumThumbnail = isShowAlbumThumbnail;
}

- (void)setIsShowAlbumNumber:(BOOL)isShowAlbumNumber {
    self.config.isShowAlbumNumber = isShowAlbumNumber;
}

- (void)setIsShowEmptyAlbum:(BOOL)isShowEmptyAlbum {
    self.config.isShowEmptyAlbum = isShowEmptyAlbum;
}

- (void)setIsOnlyShowImages:(BOOL)isOnlyShowImages {
    self.config.isOnlyShowImages = isOnlyShowImages;
}

- (void)setIsShowLivePhotoIcon:(BOOL)isShowLivePhotoIcon {
    self.config.isShowLivePhotoIcon = isShowLivePhotoIcon;
}

- (void)setIsFirstCamera:(BOOL)isFirstCamera {
    self.config.isFirstCamera = isFirstCamera;
}

- (void)setAllowsMakingVideo:(BOOL)allowsMakingVideo {
    self.config.allowsMakingVideo = allowsMakingVideo;
}

- (void)setVideoMaximumDuration:(NSTimeInterval)videoMaximumDuration {
    self.config.videoMaximumDuration = videoMaximumDuration;
}
- (void)setAlbumTitle:(NSString *)albumTitle {
    _albumTitle = [albumTitle copy];
    
    self.albumListController.title = _albumTitle;
}

- (void)setAlbumPlaceholderThumbnail:(UIImage *)albumPlaceholderThumbnail {
    _albumPlaceholderThumbnail = albumPlaceholderThumbnail;
    
    self.albumListController.placeholderThumbnail = albumPlaceholderThumbnail;
}

- (void)setPhotoNormal:(UIImage *)photoNormal {
    _photoNormal = photoNormal;
    
    self.albumListController.photoNormal = photoNormal;
    self.photoGridController.photoNormal = photoNormal;
}

- (void)setPhotoSelected:(UIImage *)photoSelected {
    _photoSelected = photoSelected;
    
    self.albumListController.photoSelected = photoSelected;
    self.photoGridController.photoSelected = photoSelected;
}

@end




















