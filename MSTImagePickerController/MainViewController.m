//
//  ViewController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MainViewController.h"
#import "MSTImagePickerController.h"

@interface MainViewController ()<UIPickerViewDelegate, UIPickerViewDataSource> {
    NSInteger _sourceType;
}
@property (weak, nonatomic) IBOutlet UIPickerView *sourceTypePickerView;
@property (weak, nonatomic) IBOutlet UISwitch *isMultiSelected;
@property (weak, nonatomic) IBOutlet UITextField *maxSelectedNum;
@property (weak, nonatomic) IBOutlet UITextField *numberOfRow;
@property (weak, nonatomic) IBOutlet UISwitch *isShowMasking;
@property (weak, nonatomic) IBOutlet UISwitch *isShowSelectedAnimation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *photoGroupType;
@property (weak, nonatomic) IBOutlet UISwitch *isDesc;
@property (weak, nonatomic) IBOutlet UISwitch *isShowThumbnail;
@property (weak, nonatomic) IBOutlet UISwitch *isShowAlbumNum;
@property (weak, nonatomic) IBOutlet UISwitch *isShowEmptyAlbum;
@property (weak, nonatomic) IBOutlet UISwitch *isOnlyShowImage;
@property (weak, nonatomic) IBOutlet UISwitch *isShowLive;
@property (weak, nonatomic) IBOutlet UISwitch *isFirstCamera;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sourceType = 1;

    [self.sourceTypePickerView selectRow:1 inComponent:0 animated:NO];
}

- (IBAction)runButtonDidClicked:(UIButton *)sender {
    MSTImagePickerController *imagePicker;
    switch (_sourceType) {
        case 0:
            imagePicker = [[MSTImagePickerController alloc] initWithAccessType:MSTImagePickerAccessTypePhotosWithoutAlbums];
            break;
        case 1:
            imagePicker = [[MSTImagePickerController alloc] initWithAccessType:MSTImagePickerAccessTypePhotosWithAlbums];
            break;
        case 2:
            imagePicker = [[MSTImagePickerController alloc] initWithAccessType:MSTImagePickerAccessTypeAlbums];
            break;
        default:
            break;
    }
    imagePicker.allowsMutiSelected = _isMultiSelected.isOn;
    imagePicker.maxSelectCount = _maxSelectedNum.text.intValue;
    imagePicker.numsInRow = _numberOfRow.text.intValue;
    imagePicker.allowsMasking = _isShowMasking.isOn;
    imagePicker.allowsSelectedAnimation = _isShowSelectedAnimation.isOn;
    imagePicker.photoMomentGroupType = _photoGroupType.selectedSegmentIndex;
    imagePicker.isPhotosDesc = _isDesc.isOn;
    imagePicker.isShowAlbumThumbnail = _isShowThumbnail.isOn;
    imagePicker.isShowAlbumNumber = _isShowAlbumNum.isOn;
    imagePicker.isShowEmptyAlbum = _isShowEmptyAlbum.isOn;
    imagePicker.isOnlyShowImages = _isOnlyShowImage.isOn;
    imagePicker.isShowLivePhotoIcon = _isShowLive.isOn;
    imagePicker.isFirstCamera = _isFirstCamera.isOn;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource & Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"无相册界面，但直接进入相册胶卷";
        case 1:
            return @"有相册界面，但直接进入相册胶卷";
        case 2:
            return @"直接进入相册界面";
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _sourceType = row;
}

#pragma mark - UITouch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_numberOfRow resignFirstResponder];
    [_maxSelectedNum resignFirstResponder];
}
@end
