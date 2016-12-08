//
//  ViewController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MainViewController.h"
#import "MSTImagePickerController.h"
#import "UIView+MSTUtils.h"
#import "DisplayCollectionViewCell.h"

@interface MainViewController ()<UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, MSTImagePickerControllerDelegate> {
    NSInteger _sourceType;
    MSTImagePickerController *imagePicker;
    NSArray *_modelsArray;
}
@property (weak, nonatomic) IBOutlet UIPickerView *sourceTypePickerView;
@property (weak, nonatomic) IBOutlet UISwitch *isMultiSelected;
@property (weak, nonatomic) IBOutlet UITextField *maxSelectedNum;
@property (weak, nonatomic) IBOutlet UITextField *numberOfRow;
@property (weak, nonatomic) IBOutlet UISwitch *isShowMasking;
@property (weak, nonatomic) IBOutlet UISwitch *isShowSelectedAnimation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showThemeType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *photoGroupType;
@property (weak, nonatomic) IBOutlet UISwitch *isDesc;
@property (weak, nonatomic) IBOutlet UISwitch *isShowThumbnail;
@property (weak, nonatomic) IBOutlet UISwitch *isShowAlbumNum;
@property (weak, nonatomic) IBOutlet UISwitch *isShowEmptyAlbum;
@property (weak, nonatomic) IBOutlet UISwitch *isOnlyShowImage;
@property (weak, nonatomic) IBOutlet UISwitch *isShowLive;
@property (weak, nonatomic) IBOutlet UISwitch *isFirstCamera;
@property (weak, nonatomic) IBOutlet UISwitch *allowsMakingVideo;
@property (weak, nonatomic) IBOutlet UISwitch *isVideoAutoSave;
@property (weak, nonatomic) IBOutlet UITextField *videoMaximumDuration;
@property (weak, nonatomic) IBOutlet UITextField *customAlbumName;
@property (weak, nonatomic) IBOutlet UICollectionView *displayCollectionView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sourceType = 1;

    [self.sourceTypePickerView selectRow:1 inComponent:0 animated:NO];
}

- (IBAction)runButtonDidClicked:(UIButton *)sender {
    MSTImagePickerAccessType type;
    switch (_sourceType) {
        case 0:
            type = MSTImagePickerAccessTypePhotosWithoutAlbums;
            break;
        case 1:
            type = MSTImagePickerAccessTypePhotosWithAlbums;
            break;
        case 2:
            type = MSTImagePickerAccessTypeAlbums;
            break;
        default:
            break;
    }
    imagePicker = [[MSTImagePickerController alloc] initWithAccessType:type];
    [self mp_setupImagePickerController];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)mp_setupImagePickerController {
    imagePicker.MSTDelegate = self;
    
    imagePicker.maxSelectCount = _maxSelectedNum.text.intValue;
    imagePicker.numsInRow = _numberOfRow.text.intValue;
    imagePicker.allowsMutiSelected = _isMultiSelected.isOn;
    imagePicker.allowsMasking = _isShowMasking.isOn;
    imagePicker.allowsSelectedAnimation = _isShowSelectedAnimation.isOn;
    imagePicker.themeStyle = _showThemeType.selectedSegmentIndex;
    imagePicker.photoMomentGroupType = _photoGroupType.selectedSegmentIndex;
    imagePicker.isPhotosDesc = _isDesc.isOn;
    imagePicker.isShowAlbumThumbnail = _isShowThumbnail.isOn;
    imagePicker.isShowAlbumNumber = _isShowAlbumNum.isOn;
    imagePicker.isShowEmptyAlbum = _isShowEmptyAlbum.isOn;
    imagePicker.isOnlyShowImages = _isOnlyShowImage.isOn;
    imagePicker.isShowLivePhotoIcon = _isShowLive.isOn;
    imagePicker.isFirstCamera = _isFirstCamera.isOn;
    imagePicker.allowsMakingVideo = _allowsMakingVideo.isOn;
    imagePicker.isVideoAutoSave = _isVideoAutoSave.isOn;
    imagePicker.videoMaximumDuration = _videoMaximumDuration.text.doubleValue;
    imagePicker.customAlbumName = _customAlbumName.text;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_numberOfRow resignFirstResponder];
    [_maxSelectedNum resignFirstResponder];
}

#pragma mark - UIPickerViewDataSource & Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    label.adjustsFontSizeToFitWidth = YES;
    
    switch (row) {
        case 0:
            label.text = @"无相册界面，但直接进入相册胶卷";
            break;
        case 1:
            label.text = @"有相册界面，但直接进入相册胶卷";
            break;
        case 2:
            label.text = @"直接进入相册界面";
            break;
        default:
            label.text = @"";
            break;
    }
    [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 16, 20)];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _sourceType = row;
}

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItems:%zi", _modelsArray.count);
    return _modelsArray.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DisplayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    if (indexPath.item >= _modelsArray.count) {
        cell.image = [UIImage imageNamed:@"icon_add"];
    } else {
        MSTPickingModel *model = _modelsArray[indexPath.item];
        cell.image = model.image;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= _modelsArray.count) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (int i = 0; i < _modelsArray.count; i++) {
            MSTPickingModel *model = _modelsArray[i];
            [array addObject:model.identifier];
        }
        MSTImagePickerAccessType type;
        switch (_sourceType) {
            case 0:
                type = MSTImagePickerAccessTypePhotosWithoutAlbums;
                break;
            case 1:
                type = MSTImagePickerAccessTypePhotosWithAlbums;
                break;
            case 2:
                type = MSTImagePickerAccessTypeAlbums;
                break;
            default:
                break;
        }
        imagePicker = [[MSTImagePickerController alloc] initWithAccessType:type identifiers:array];
        [self mp_setupImagePickerController];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - MSTImagePickerControllerDelegate
- (void)MSTImagePickerControllerDidCancel:(MSTImagePickerController *)picker {
    NSLog(@"mstImagePickerControllerDidCancel");
}

- (void)MSTImagePickerController:(MSTImagePickerController *)picker didFinishPickingMediaWithArray:(NSArray<MSTPickingModel *> *)array {
    _modelsArray = array;
    NSLog(@"difFinishArray:__%zi", array.count);
    [self.displayCollectionView reloadData];
}

-(void)MSTImagePickerController:(MSTImagePickerController *)picker didFinishPickingVideoWithURL:(NSURL *)videoURL identifier:(NSString *)localIdentifier {
    NSLog(@"didfinishVideo:_url__%@___localIdentifier:%@", videoURL, localIdentifier);
}

@end
