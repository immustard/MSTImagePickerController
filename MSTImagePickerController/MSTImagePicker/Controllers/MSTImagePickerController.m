//
//  MSTImagePickerController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTImagePickerController.h"
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
    
    [self setToolbarHidden:NO animated:YES];
    
    [self mp_checkAuthorizationStatus];
}

#pragma mark - Initialized Methods
- (instancetype)initWithAccessType:(MSTImagePickerAccessType)accessType{
    if (self = [super init]) {
        self.accessType = accessType;
        [self mp_setupFirstTimeProperties];
    }
    return self;
}

#pragma mark - Instance Methods
- (void)mp_setupFirstTimeProperties {
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    config.allowsMutiSelected = YES;
    config.maxSelectCount = 9;
    config.numsInRow = 4;
    config.allowsMasking = YES;
    config.allowsSelectedAnimation = YES;
    config.photoMomentGroupType = MSTImageMomentGroupTypeNone;
    config.isPhotosDesc = YES;
    config.isShowAlbumThumbnail = YES;
    config.isShowAlbumNumber = YES;
    config.isShowEmptyAlbum = NO;
    config.isOnlyShowImages = NO;
    config.isShowLivePhotoIcon = YES;
    config.isFirstCamera = YES;
    self.albumTitle = NSLocalizedStringFromTable(@"str_photos", @"MSTImagePicker", @"相册");
}

/**
 检查授权访问状态
 */
- (void)mp_checkAuthorizationStatus {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                    NSLog(@"PHAuthorizationStatusNotDetermined");
                    break;
                case PHAuthorizationStatusRestricted:
                    NSLog(@"PHAuthorizationStatusRestricted");
                    break;
                case PHAuthorizationStatusDenied:{
                    NSLog(@"PHAuthorizationStatusDenied");
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTable(@"str_allow_photoLibrary", @"MSTImagePicker", @"允许访问") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"str_confirm", @"MSTImagePicker", @"确认") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alertController addAction:action];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    break;
                }
                case PHAuthorizationStatusAuthorized:{
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
    } else {
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




















