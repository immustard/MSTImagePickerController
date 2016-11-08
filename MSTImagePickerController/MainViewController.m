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

@interface MainViewController ()<UIPickerViewDelegate, UIPickerViewDataSource, MSTImagePickerControllerDelegate> {
    NSInteger _sourceType;
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

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sourceType = 1;

    [self.sourceTypePickerView selectRow:1 inComponent:0 animated:NO];
}

- (IBAction)endEditing:(UITapGestureRecognizer *)sender {
    [_numberOfRow resignFirstResponder];
    [_maxSelectedNum resignFirstResponder];
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
    imagePicker.MSTDelegate = self;
    
    imagePicker.allowsMutiSelected = _isMultiSelected.isOn;
    imagePicker.maxSelectCount = _maxSelectedNum.text.intValue;
    imagePicker.numsInRow = _numberOfRow.text.intValue;
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
    [self presentViewController:imagePicker animated:YES completion:nil];
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

#pragma mark - MSTImagePickerControllerDelegate
- (void)MSTImagePickerControllerDidCancel:(MSTImagePickerController *)picker {
    NSLog(@"mstImagePickerControllerDidCancel");
}

- (void)MSTImagePickerController:(MSTImagePickerController *)picker didFinishPickingMediaWithArray:(NSArray<MSTPickingModel *> *)array {
    NSLog(@"difFinishArray:__%@", array);
    for (int i = 0; i < array.count; ++i) {
        MSTPickingModel *model = array[i];
        
        NSLog(@"^____byte:%@", [NSByteCountFormatter stringFromByteCount:UIImageJPEGRepresentation(model.image, 1).length countStyle:NSByteCountFormatterCountStyleFile]);
        
        NSString *string = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        [[NSFileManager defaultManager] createFileAtPath:[string stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", i]] contents:UIImageJPEGRepresentation(model.image, 1) attributes:nil];
    }
}

-(void)MSTImagePickerController:(MSTImagePickerController *)picker didFinishPickingVideoWithURL:(NSURL *)videoURL identifier:(NSString *)localIdentifier {
    NSLog(@"didfinishVideo:_url__%@___localIdentifier:%@", videoURL, localIdentifier);
}

@end
