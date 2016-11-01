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
#import "UIView+MSTUtils.h"
#import "MSTPhotoManager.h"
#import "MSTAlbumModel.h"

@interface MSTImagePickerController () {
    BOOL _toolBarEnbled;
}

@property (strong, nonatomic) MSTPhotoConfiguration *config;

@property (assign, nonatomic) MSTImagePickerAccessType accessType;

@property (strong, nonatomic) MSTAlbumListController *albumListController;
@property (strong, nonatomic) MSTPhotoGridController *photoGridController;

@property (strong, nonatomic) UIAlertController *maxSelectedAlertController;

@property (strong, nonatomic) NSMutableArray <MSTAssetModel *>*pickedModels;
@property (strong, nonatomic) NSMutableArray <NSString *>*pickedModelIdentifiers;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *originalImageButton;
@property (strong, nonatomic) UIButton *originalTextButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *pickedCountLabel;
@property (strong, nonatomic) UILabel *originalSizeLabel;

@end

@implementation MSTImagePickerController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setToolbarHidden:NO animated:NO];
    
    [self mp_setupNavigationBar];
    [self mp_setupToolBar];
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
- (BOOL)addSelectedAsset:(MSTAssetModel *)asset {
    if (self.pickedModels.count == self.config.maxSelectCount) {
        
        [self presentViewController:self.maxSelectedAlertController animated:YES completion:nil];
        
        return NO;
    }
    
    //已经保存过
    if ([self containAssetModel:asset]) return YES;
    
    asset.selected = YES;
    [self.pickedModels addObject:asset];
    [self.pickedModelIdentifiers addObject:asset.identifier];
    
    [self mp_refreshToolBar];
    
    return YES;
}

- (BOOL)removeSelectedAsset:(MSTAssetModel *)asset {
    if ([self.pickedModelIdentifiers containsObject:asset.identifier]) {
        asset.selected = NO;
        
        NSInteger index = [self.pickedModelIdentifiers indexOfObject:asset.identifier];
        
        [self.pickedModelIdentifiers removeObjectAtIndex:index];
        [self.pickedModels removeObjectAtIndex:index];
        
        [self mp_refreshToolBar];
        
        return YES;
    }
    return NO;
}

- (BOOL)containAssetModel:(MSTAssetModel *)asset {
    return [self.pickedModelIdentifiers containsObject:asset.identifier];
}

- (NSInteger)hasSelected {
    return self.pickedModelIdentifiers.count;
}

- (BOOL)isFullImage {
    return self.originalImageButton.isSelected;
}

- (void)setFullImageOption:(BOOL)isFullImage {
    self.originalTextButton.selected = isFullImage;
    self.originalImageButton.selected = isFullImage;
    
    [self mp_refreshOriginalImageSize];
}

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

- (void)mp_setupToolBar {
    _toolBarEnbled = NO;
    [self mp_setupToolBarButtonEnbled];
    self.originalSizeLabel.text = @"";
}

- (void)mp_setupToolBarButtonEnbled {
    [self.previewButton setEnabled:_toolBarEnbled];
    [self.originalImageButton setEnabled:_toolBarEnbled];
    [self.originalTextButton setEnabled:_toolBarEnbled];
    [self.doneButton setEnabled:_toolBarEnbled];
    self.pickedCountLabel.hidden = !_toolBarEnbled;
    
    if (_toolBarEnbled) {
        [self.originalImageButton setSelected:NO];
        [self.originalTextButton setSelected:NO];
    }
}

- (void)mp_refreshToolBar {
    if (self.pickedModelIdentifiers.count) {
        if (!_toolBarEnbled) {
            _toolBarEnbled = YES;
            [self mp_setupToolBarButtonEnbled];
        }
        self.pickedCountLabel.text = [NSString stringWithFormat:@"%zi", self.pickedModelIdentifiers.count];
        if (self.config.allowsSelectedAnimation) [self.pickedCountLabel addSpringAnimation];
    } else {
        _toolBarEnbled = NO;
        [self mp_setupToolBarButtonEnbled];
    }
    
    [self mp_refreshOriginalImageSize];
}

- (CGFloat)mp_calculateWidthWithString:(NSString *)string textSize:(CGFloat)textSize {
    return [string boundingRectWithSize:CGSizeMake(300, 44) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:textSize]} context:nil].size.width;
}

- (void)mp_previewButtonDidClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

- (void)mp_doneButtonDidClicked:(UIButton *)sender {
    
}

- (void)mp_originalImageButtonDidClicked:(UIButton *)sender {
    BOOL selected = !sender.selected;
    self.originalTextButton.selected = selected;
    self.originalImageButton.selected = selected;
    
    [self mp_refreshOriginalImageSize];
}

- (void)mp_refreshOriginalImageSize {
    if (self.originalImageButton.isSelected && self.originalImageButton.isEnabled) {
        [[MSTPhotoManager sharedInstance] getImageBytesWithArray:self.pickedModels completionBlock:^(NSString *result) {
            self.originalSizeLabel.text = [NSString stringWithFormat:@"(%@)", result];
        }];
    } else {
        self.originalSizeLabel.text = @"";
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
    }
    return _albumListController;
}

- (MSTPhotoGridController *)photoGridController{
    if (!_photoGridController) {
        self.photoGridController = [[MSTPhotoGridController alloc] initWithCollectionViewLayout:[MSTPhotoGridController flowLayoutWithNumInALine:self.config.numsInRow]];
        [[MSTPhotoManager alloc] loadCameraRollInfoisDesc:self.config.isPhotosDesc isShowEmpty:self.config.isShowEmptyAlbum isOnlyShowImage:self.config.isOnlyShowImages CompletionBlock:^(MSTAlbumModel *result) {
            _photoGridController.album = result;
        }];
    }
    return _photoGridController;
}

- (UIAlertController *)maxSelectedAlertController {
    if (!_maxSelectedAlertController) {
        self.maxSelectedAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"str_get_to_maximum_selected", @"MSTImagePicker", @"最大选择数量提示"), self.config.maxSelectCount] message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"str_i_see", @"MSTImagePicker", @"我知道了") style:UIAlertActionStyleDefault handler:nil];
        [_maxSelectedAlertController addAction:okAction];
    }
    return _maxSelectedAlertController;
}

- (NSMutableArray *)pickedModels {
    if (!_pickedModels) {
        self.pickedModels = [NSMutableArray array];
    }
    return _pickedModels;
}

- (NSMutableArray<NSString *> *)pickedModelIdentifiers {
    if (!_pickedModelIdentifiers) {
        self.pickedModelIdentifiers = [NSMutableArray array];
    }
    return _pickedModelIdentifiers;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_preview", @"MSTImagePicker", @"预览");

        self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(0, 0, [self mp_calculateWidthWithString:string textSize:17] + 20, 44);
        [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

        _previewButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_previewButton setTitle:string forState:UIControlStateNormal];

        [_previewButton addTarget:self action:@selector(mp_previewButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_previewButton];
    }
    return _previewButton;
}

- (UIButton *)originalImageButton {
    if (!_originalImageButton) {
        self.originalImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalImageButton.frame = CGRectMake(self.previewButton.right, 5, 34, 34);
        [_originalImageButton setImage:[UIImage imageNamed:@"icon_full_image_normal"] forState:UIControlStateNormal];
        [_originalImageButton setImage:[UIImage imageNamed:@"icon_full_image_selected"] forState:UIControlStateSelected];
        [_originalImageButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        [_originalImageButton addTarget:self action:@selector(mp_originalImageButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_originalImageButton];
    }
    return _originalImageButton;
}

- (UIButton *)originalTextButton {
    if (!_originalTextButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_original", @"MSTImagePicker", @"原图");
        
        self.originalTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalTextButton.frame = CGRectMake(self.originalImageButton.right, 0, [self mp_calculateWidthWithString:string textSize:15], 44);
        [_originalTextButton setTitle:string forState:UIControlStateNormal];
        _originalTextButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originalTextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalTextButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        
        [_originalTextButton addTarget:self action:@selector(mp_originalImageButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];

        [self.toolbar addSubview:_originalTextButton];
    }
    return _originalTextButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_done", @"MSTImagePicker", @"完成");
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(self.toolbar.width-[self mp_calculateWidthWithString:string textSize:17]-20, 0, [self mp_calculateWidthWithString:string textSize:17] + 20, 44);
        [_doneButton setTitle:string forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.65 green:0.82 blue:0.88 alpha:1.00] forState:UIControlStateDisabled];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        [_doneButton addTarget:self action:@selector(mp_doneButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_doneButton];
    }
    return _doneButton;
}

- (UILabel *)pickedCountLabel {
    if (!_pickedCountLabel) {
        self.pickedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.doneButton.left - 28, 8, 28, 28)];
        _pickedCountLabel.textColor = [UIColor whiteColor];
        _pickedCountLabel.font = [UIFont systemFontOfSize:15];
        _pickedCountLabel.backgroundColor = [UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00];
        _pickedCountLabel.textAlignment = NSTextAlignmentCenter;
        [_pickedCountLabel MSTAddCornorRadius:14];
        
        [self.toolbar addSubview:_pickedCountLabel];
    }
    return _pickedCountLabel;
}

- (UILabel *)originalSizeLabel {
    if (!_originalSizeLabel) {
        self.originalSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.originalTextButton.right, 0, 80, 44)];
        _originalSizeLabel.font = [UIFont systemFontOfSize:13];
        _originalSizeLabel.textColor = [UIColor blackColor];
        
        [self.toolbar addSubview:_originalSizeLabel];
    }
    return _originalSizeLabel;
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

- (void)setAllowsPickGIF:(BOOL)allowsPickGIF {
    self.config.allowsPickGIF = allowsPickGIF;
}

- (void)setVideoMaximumDuration:(NSTimeInterval)videoMaximumDuration {
    self.config.videoMaximumDuration = videoMaximumDuration;
}

- (void)setCustomAlbumName:(NSString *)customAlbumName {
    self.config.customAlbumName = customAlbumName;
}

- (void)setAlbumTitle:(NSString *)albumTitle {
    self.albumListController.title = _albumTitle;
}

- (void)setAlbumPlaceholderThumbnail:(UIImage *)albumPlaceholderThumbnail {
    self.albumListController.placeholderThumbnail = albumPlaceholderThumbnail;
}

- (void)setPhotoNormal:(UIImage *)photoNormal {
    self.config.photoNormal = photoNormal;
}

- (void)setPhotoSelected:(UIImage *)photoSelected {
    self.config.photoSelected = photoSelected;
}

- (void)setCameraImage:(UIImage *)cameraImage {
    self.config.cameraImage = cameraImage;
}

@end




















