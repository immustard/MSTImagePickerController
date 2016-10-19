//
//  MSTPhotoGridController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoGridController.h"
#import "MSTPhotoManager.h"
#import "MSTPhotoConfiguration.h"
#import "UICollectionView+MSTUtils.h"
#import "NSIndexSet+MSTUtils.h"
#import "MSTAlbumModel.h"
#import "MSTPhotoGridCell.h"
#import "MSTPhotoGridHeaderView.h"
#import "NSDate+MSTUtils.h"
#import "MSTPhotoPreviewController.h"

static NSString * const reuserIdentifier = @"MSTPhotoGridCell";

@interface MSTPhotoGridController ()<PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout> {
    CGSize _cellSize;
    CGSize _thumnailSize;               //缩略图尺寸，计算时包括 scale
    CGRect _previousPreheatRect;        //缓存区域
    
    BOOL _isMoment;                     //是否按时间分组，is grouped by creationDate
    NSArray *_momentsArray;
}
@property (strong, nonatomic) MSTPhotoConfiguration *config;

@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (strong, nonatomic) PHImageRequestOptions *imageRequestOptions;
@end

@implementation MSTPhotoGridController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mp_initData];
    [self mp_setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.config.isPhotosDesc) {
        if (_isMoment) {
            MSTMoment *moment = _momentsArray.lastObject;
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:moment.assets.count-1 inSection:_momentsArray.count-1] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        } else {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.album.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Class Methods
+ (UICollectionViewFlowLayout *)flowLayoutWithNumInALine:(int)num {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = CGSizeMake((screenSize.width-4) / (CGFloat)num - 4, (screenSize.width-4) / (CGFloat)num - 4);
    flowLayout.minimumLineSpacing = 4;
    flowLayout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    
    return flowLayout;
}

#pragma mark - Instance Methods
- (void)mp_initData {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat num = (CGFloat)self.config.numsInRow;
    _cellSize = CGSizeMake((screenSize.width-4) / num - 4, (screenSize.width-4) / num - 4);
    _thumnailSize = CGSizeMake(_cellSize.width * scale, _cellSize.height * scale);
    
    [self mp_stopCacheImages];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)mp_stopCacheImages {
    [self.imageManager stopCachingImagesForAllAssets];
    _previousPreheatRect = CGRectZero;
}

- (void)mp_setupViews {
    [self.collectionView registerClass:[MSTPhotoGridCell class] forCellWithReuseIdentifier:reuserIdentifier];
    [self.collectionView registerClass:[MSTPhotoGridHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MSTPhotoGridHeaderView"];

    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)mp_refreshMoments {
    _momentsArray = nil;
    _momentsArray = [[MSTPhotoManager sharedInstance] sortByMomentType:self.config.photoMomentGroupType assets:_album.content];
}

#pragma mark - Lazy Load
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (PHImageRequestOptions *)imageRequestOptions {
    if (!_imageRequestOptions) {
        self.imageRequestOptions = [[PHImageRequestOptions alloc] init];
        _imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    }
    return _imageRequestOptions;
}

- (MSTPhotoConfiguration *)config {
    if (!_config) {
        self.config = [MSTPhotoConfiguration defaultConfiguration];
    }
    return _config;
}

#pragma mark - Setter
- (void)setAlbum:(MSTAlbumModel *)album {
    _album = album;
    
    self.title = album.albumName;
    
    self.config.photoMomentGroupType == MSTImageMomentGroupTypeNone ? _isMoment = NO : (_isMoment = YES);
    
    if (_isMoment) {
        [self mp_refreshMoments];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_isMoment) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        return CGSizeMake(size.width, 44);
    }
    return CGSizeZero;
}

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_isMoment) return _momentsArray.count;
        else return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_isMoment) {
        MSTMoment *moment = _momentsArray[section];
        return moment.assets.count;
    } else {
        return self.album.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset;
    
    if (_isMoment) {
        MSTMoment *moment = _momentsArray[indexPath.section];
        asset = moment.assets[indexPath.row];
    } else {
        asset = self.album.content[indexPath.row];
    }
    
    MSTPhotoGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserIdentifier forIndexPath:indexPath];
    [self.imageManager requestImageForAsset:asset targetSize:_thumnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell setImage:result targetSize:_cellSize];
        cell.asset = asset;
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    MSTMoment *moment = _momentsArray[indexPath.section];
    MSTPhotoGridHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MSTPhotoGridHeaderView" forIndexPath:indexPath];
    header.textLabel.text = [moment.date stringByPhotosMomentsType:self.config.photoMomentGroupType];
    
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MSTPhotoPreviewController *ppc = [[MSTPhotoPreviewController alloc] init];
    [self.navigationController pushViewController:ppc animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // 检测是否有资源变化
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:_album.content];
    if (!collectionChanges) {
        return;
    }
    
    // 界面更新, update interfaces
    dispatch_async(dispatch_get_main_queue(), ^{
        self.album.content = [collectionChanges fetchResultAfterChanges];
        UICollectionView *collectionView = self.collectionView;

        if (_isMoment) {
#warning 等待解决   wait for updating
            [self mp_refreshMoments];
            [collectionView reloadData];
        } else {
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                
                [collectionView reloadData];
            } else {
                // 如果相册有变化，collectionview动画增删改
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count] > 0) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes indexPathsFromIndexesWithSection:0]];
                    }
                    
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count] > 0) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes indexPathsFromIndexesWithSection:0]];
                    }
                    
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count] > 0) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes indexPathsFromIndexesWithSection:0]];
                    }
                } completion:nil];
            }
        }
    });
}
@end

























