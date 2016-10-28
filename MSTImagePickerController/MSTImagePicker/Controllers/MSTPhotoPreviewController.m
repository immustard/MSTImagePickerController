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

@interface MSTPhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource> {
    MSTAlbumModel *_albumModel;
    MSTMoment *_moment;
    NSIndexPath *_indexPath;
}

@property (strong, nonatomic) UICollectionView *myCollectionView;

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
}

#pragma mark - Instance Methods
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didSelectedWithAlbum:(MSTAlbumModel *)album indexPath:(NSIndexPath *)indexPath {
    _albumModel = album;
    _indexPath = indexPath;
}

- (void)mp_setupSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.myCollectionView.contentOffset = CGPointMake(0, 0);
    [self.myCollectionView setContentSize:CGSizeMake((self.view.width + 20)*5, self.view.height)];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = [UIColor orangeColor];
    backBtn.frame = CGRectMake(20, 20, 50, 50);
    
    [backBtn addTarget:self action:@selector(mp_backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [self.myCollectionView scrollToItemAtIndexPath:_indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    MSTPhotoPreviewImageCell *cell = (MSTPhotoPreviewImageCell *)[_myCollectionView cellForItemAtIndexPath:_indexPath];
    [cell didDisplayed];
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

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSTPhotoPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSTPhotoPreviewImageCell" forIndexPath:indexPath];
    cell.model = _albumModel.models[indexPath.item];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
#warning waiting for updating 确认哪个，不想循环，虽然最多只有2个。
    for (MSTPhotoPreviewImageCell *cell in _myCollectionView.visibleCells) {
        [cell didDisplayed];
    }
}

@end
