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
    
    self.myCollectionView.contentOffset = CGPointMake(0, 0);
    [self.myCollectionView setContentSize:CGSizeMake((self.view.width + 20)*5, self.view.height)];
}

#pragma mark - Lazy Load
- (UICollectionView *)myCollectionView {
    if (!_myCollectionView) {
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:[self mp_flowLayout]];
        _myCollectionView.pagingEnabled = YES;
        _myCollectionView.showsHorizontalScrollIndicator = NO;
        _myCollectionView.backgroundColor = [UIColor blackColor];
        _myCollectionView.scrollsToTop = NO;
        
        _myCollectionView.dataSource = self;
        _myCollectionView.delegate = self;
        
        [self.view addSubview:_myCollectionView];
        
        [_myCollectionView registerClass:[MSTPhotoPreviewImageCell class] forCellWithReuseIdentifier:@"MSTPhotoPreviewImageCell"];
    }
    return _myCollectionView;
}

#pragma mark - Instance Methods
- (void)didSelectedWithAlbum:(MSTAlbumModel *)album indexPath:(NSIndexPath *)indexPath {
    _albumModel = album;
    
    [self.myCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (UICollectionViewFlowLayout *)mp_flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    
    return flowLayout;
}

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSTPhotoPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSTPhotoPreviewImageCell" forIndexPath:indexPath];
    cell.asset = _albumModel.content[indexPath.row];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
#warning waiting for updating 确认哪个，不想循环，虽然最多只有2个。
    for (MSTPhotoPreviewImageCell *cell in _myCollectionView.visibleCells) {
        [cell didDisplayed];
    }
}

@end
