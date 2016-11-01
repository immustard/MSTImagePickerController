//
//  MSTPhotoPreviewController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoPreviewController.h"
#import "MSTAlbumModel.h"
#import "MSTMoment.h"
#import "UIView+MSTUtils.h"
#import "MSTPhotoPreviewImageCell.h"
#import "MSTImagePickerController.h"

@interface MSTPhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource> {
    MSTAlbumModel *_albumModel;
    MSTMoment *_moment;
    NSInteger _currentItem;
    
    MSTImagePickerStyle _pickerStyle;
    BOOL _isShowAnimation;
}

@property (strong, nonatomic) UICollectionView *myCollectionView;

@property (strong, nonatomic) UIView *customNavigationBar;
@property (strong, nonatomic) UIView *customToolBar;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UIButton *originalImageButton;
@property (strong, nonatomic) UIButton *originalTextButton;

@end

@implementation MSTPhotoPreviewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mp_setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(photoPreviewDisappear)]) [self.delegate photoPreviewDisappear];
}

#pragma mark - Instance Methods
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didSelectedWithAlbum:(MSTAlbumModel *)album item:(NSInteger)item {
    _albumModel = album;
    _currentItem = item;
}

- (void)mp_setupSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.myCollectionView.contentOffset = CGPointMake(0, 0);
    [self.myCollectionView setContentSize:CGSizeMake((self.view.width + 20)*5, self.view.height)];

    [self.myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
#warning waiting for fixing 这里的 cell 为 nil
    //清晰显示，但是失败了。。。=-=
    MSTPhotoPreviewImageCell *cell = (MSTPhotoPreviewImageCell *)[_myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItem inSection:0]];
    [cell didDisplayed];
    
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    _pickerStyle = config.themeStyle;
    _isShowAnimation = config.allowsSelectedAnimation;
    switch (_pickerStyle) {
        case MSTImagePickerStyleDark:
            self.myCollectionView.backgroundColor = [UIColor blackColor];
            break;
        case MSTImagePickerStyleLight:
            self.myCollectionView.backgroundColor = kLightStyleBGColor;
            break;
        default:
            break;
    }
    
    [self mp_setupCustomNavigationBar];
    [self mp_setupCustomToolBar];
    
    [self mp_refreshCustomBars];
}

- (void)mp_setupCustomNavigationBar {
    self.customNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 64, 64);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(22, 22, 22, 22)];
    [backButton addTarget:self action:@selector(mp_backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    switch (_pickerStyle) {
        case MSTImagePickerStyleLight:
            _customNavigationBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
            [backButton setImage:[UIImage imageNamed:@"icon_preview_back_light"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_preview_selected_light"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_picture_selected"] forState:UIControlStateSelected];
            break;
        case MSTImagePickerStyleDark:
            _customNavigationBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
            [backButton setImage:[UIImage imageNamed:@"icon_preview_back_dark"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_picture_normal"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_picture_selected"] forState:UIControlStateSelected];
            break;
    }
    
    [self.view addSubview:_customNavigationBar];
    [_customNavigationBar addSubview:backButton];
    [_customNavigationBar addSubview:_selectedButton];
}

- (void)mp_setupCustomToolBar {
    self.customToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    
    
}

- (void)mp_refreshCustomBars {
    MSTImagePickerController *pickerCtrler = (MSTImagePickerController *)self.navigationController;
    
    MSTAssetModel *currentModel = _albumModel.models[_currentItem];
    //检查是否为选中照片
    self.selectedButton.selected = [pickerCtrler containAssetModel:currentModel];
}

- (UICollectionViewFlowLayout *)mp_flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    
    return flowLayout;
}

- (void)mp_backButtonDidClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mp_selectedButtonDidClicked:(UIButton *)sender {
    MSTImagePickerController *pickerCtrler = (MSTImagePickerController *)self.navigationController;
    MSTAssetModel *model = _albumModel.models[_currentItem];
    
    if (sender.isSelected) {
        //选中情况
        sender.selected = NO;
        [pickerCtrler removeSelectedAsset:model];
    } else {
        sender.selected = [pickerCtrler addSelectedAsset:model];
        
        if (sender.isSelected && _isShowAnimation) [sender addSpringAnimation];
    }
}

#pragma mark - Lazy Load
- (UICollectionView *)myCollectionView {
    if (!_myCollectionView) {
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:[self mp_flowLayout]];
        _myCollectionView.pagingEnabled = YES;
        _myCollectionView.showsHorizontalScrollIndicator = NO;
        _myCollectionView.scrollsToTop = NO;
        
        _myCollectionView.dataSource = self;
        _myCollectionView.delegate = self;
        
        [self.view addSubview:_myCollectionView];
        [self.view sendSubviewToBack:_myCollectionView];
        
        [_myCollectionView registerClass:[MSTPhotoPreviewImageCell class] forCellWithReuseIdentifier:@"MSTPhotoPreviewImageCell"];
    }
    return _myCollectionView;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        self.selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.frame = CGRectMake(kScreenWidth-64, 0, 64, 64);
        [_selectedButton setImageEdgeInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        [_selectedButton addTarget:self action:@selector(mp_selectedButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSTPhotoPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSTPhotoPreviewImageCell" forIndexPath:indexPath];
    cell.model = _albumModel.models[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MSTPhotoPreviewImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell recoverSubviews];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(MSTPhotoPreviewImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell recoverSubviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentItem = offSetWidth / (self.view.width + 20);
    
    if (_currentItem != currentItem) {
        _currentItem = currentItem;
        [self mp_refreshCustomBars];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
#warning waiting for updating 确认哪个，不想循环，虽然最多只有2个。
    for (MSTPhotoPreviewImageCell *cell in _myCollectionView.visibleCells) {
        [cell didDisplayed];
    }
}

@end
