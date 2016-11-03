//
//  MSTVideoPreviewController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/11/2.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTVideoPreviewController.h"
#import "MSTImagePickerController.h"
#import "MSTPhotoConfiguration.h"
#import "UIView+MSTUtils.h"
#import "MSTAssetModel.h"
#import "MSTPhotoManager.h"

@interface MSTVideoPreviewController () {
    BOOL _isPlay;
    PHAsset *_asset;
}
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *playButton;

@property (strong, nonatomic) UIView *customToolBar;

@property (strong, nonatomic) UIButton *doneButton;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation MSTVideoPreviewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mp_setupSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mp_appWillRisgnActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization Method
- (instancetype)initWithAsset:(PHAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
    }
    return self;
}

#pragma mark - Instance Method
- (BOOL)prefersStatusBarHidden {
    if (_isPlay)
        return YES;
    else
        return NO;
}

- (void)mp_setupSubviews {
    [[MSTPhotoManager sharedInstance] getAVPlayerItemFromPHAsset:_asset completionBlock:^(AVPlayerItem *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.player = [AVPlayer playerWithPlayerItem:item];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mp_endPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        });
    }];
    self.showsPlaybackControls = NO;
    
    [self mp_setupCustomToolBar];
    [self playButton];
}

- (void)mp_setupCustomToolBar {
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    
    self.customToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    
    switch (config.themeStyle) {
        case MSTImagePickerStyleLight:
            _customToolBar.backgroundColor = [UIColor colorWithWhite:1 alpha:.7];
            break;
        case MSTImagePickerStyleDark:
            _customToolBar.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
            break;
    }
    
    [self.view addSubview:_customToolBar];
    [_customToolBar addSubview:self.doneButton];
}

- (void)mp_backButtonDidClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mp_playButtonDidClicked:(UIButton *)sender {
    if (!_isPlay) {
        _isPlay = YES;
        [sender setImage:nil forState:UIControlStateNormal];
        [sender setImage:nil forState:UIControlStateHighlighted];
        
        [self mp_showBars:NO];
        
        [self.player play];
    } else {
        _isPlay = NO;
        [_playButton setImage:[UIImage imageNamed:@"icon_preview_video_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"icon_preview_video_play_highlighted"] forState:UIControlStateHighlighted];
        
        [self mp_showBars:YES];
        
        [self.player pause];
    }
}

- (void)mp_doneButtonDidClicked:(UIButton *)sender {
    
}

- (void)mp_endPlaying {
    [self mp_playButtonDidClicked:self.playButton];
    [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
}

- (void)mp_appWillRisgnActive {
    if (_isPlay) {
        [self mp_playButtonDidClicked:self.playButton];
    }
}

- (void)mp_showBars:(BOOL)isShow {
    [self.navigationController setNavigationBarHidden:!isShow animated:NO];
    self.customToolBar.hidden = !isShow;
    
    [super prefersStatusBarHidden];
}

#pragma mark - Lazy Load
- (UIButton *)playButton {
    if (!_playButton) {
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton setImage:[UIImage imageNamed:@"icon_preview_video_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"icon_preview_video_play_highlighted"] forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(mp_playButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_playButton];

        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [self.view addConstraints:@[leading, top, trailing, bottom]];

    }
    return _playButton;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.view.frame;
    }
    return _playerLayer;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_done", @"MSTImagePicker", @"完成");
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(kScreenWidth-60, 0, 60, 44);
        [_doneButton setTitle:string forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.65 green:0.82 blue:0.88 alpha:1.00] forState:UIControlStateDisabled];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        [_doneButton addTarget:self action:@selector(mp_doneButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}
@end
