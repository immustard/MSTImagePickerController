//
//  MSTPhotoGridController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoGridController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+MSTUtils.h"
#import "UIView+MSTUtils.h"
#import "NSDate+MSTUtils.h"
#import "MSTPhotoManager.h"
#import "MSTPhotoConfiguration.h"
#import "UICollectionView+MSTUtils.h"
#import "NSIndexSet+MSTUtils.h"
#import "MSTAlbumModel.h"
#import "MSTMoment.h"
#import "MSTPhotoGridCell.h"
#import "MSTPhotoGridHeaderView.h"
#import "MSTPhotoPreviewController.h"
#import "MSTImagePickerController.h"

static NSString * const reuserIdentifier = @"MSTPhotoGridCell";

@interface MSTPhotoGridController ()<PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MSTPhotoGridCellDelegate, MSTPhotoPreviewControllerDelegate> {
    BOOL _isFirstAppear;
    
    BOOL _isShowCamera;
    BOOL _isMoment;                     //是否按时间分组，is grouped by creationDate
    NSArray *_momentsArray;
}
@property (strong, nonatomic) MSTPhotoConfiguration *config;

@end

@implementation MSTPhotoGridController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavigationRightCancelButton];
    
    _isFirstAppear = YES;
    
    [self mp_initData];
    [self mp_setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
#warning waiting for updating 滚动到最下方，找到最佳方案
    if (!self.config.isPhotosDesc && _isFirstAppear) {
        [self mp_scrollToBottom];
        _isFirstAppear = NO;
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
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
#warning waiting for testing 在图片特别多的情况下，测试选中状态是否正常
    dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT), ^{
        [self mp_checkSelectedStatus];
        
        if (_isMoment) {
            [self mp_refreshMoments];
        }
    });
}

/**
 判断是否选中
 */
- (void)mp_checkSelectedStatus {
    MSTImagePickerController *pickerCtrler = (MSTImagePickerController *)self.navigationController;
    for (MSTAssetModel *model in _album.models) {
        model.selected = [pickerCtrler containAssetModel:model];
    }
#warning waiting for testing 这里不知道在图片特别多的情况下是不是需要刷新界面
}

- (void)mp_setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.top = 64;
    self.collectionView.height = self.view.height - 64 - 44;
    
    [self.collectionView registerClass:[MSTPhotoGridCell class] forCellWithReuseIdentifier:reuserIdentifier];
    [self.collectionView registerClass:[MSTPhotoGridHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MSTPhotoGridHeaderView"];
    if (_isShowCamera) [self.collectionView registerClass:[MSTPhotoGridCameraCell class] forCellWithReuseIdentifier:@"MSTPhotoGridCameraCell"];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)mp_refreshMoments {
    _momentsArray = nil;
    _momentsArray = [[MSTPhotoManager sharedInstance] sortByMomentType:self.config.photoMomentGroupType assets:_album.models];
}

- (void)mp_scrollToBottom {
    NSInteger item;
    NSInteger section;
    
    if (_isMoment) {
        MSTMoment *moment = _momentsArray.lastObject;
        item = moment.assets.count-1;
        section = _momentsArray.count-1;
    } else {
        item = self.album.count - 1;
        section = 0;
    }
    
    _isShowCamera ? item++ : item;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (MSTPhotoGridCameraCell *)mp_addCameraCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    MSTPhotoGridCameraCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSTPhotoGridCameraCell" forIndexPath:indexPath];
    if (self.config.cameraImage) cell.cameraImage = self.config.cameraImage;
    return cell;
}

#pragma mark - Lazy Load
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
#warning waiting for updating 当显示照相机并且根据moment分组的时候，把照相机放在当前时间组，没有就创建一个分组。
    _isShowCamera = self.config.isFirstCamera && self.album.isCameraRoll;
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
    if (_isMoment) {
        return _momentsArray.count;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_isMoment) {
        //按时间分组的情况
        MSTMoment *moment = _momentsArray[section];
        if (_isShowCamera && ((self.config.isPhotosDesc && !section) || (!self.config.isPhotosDesc && section == _momentsArray.count-1))) {
            //有相机, 并且正序第一段或倒序最后一段
            return moment.assets.count + 1;
        } else {
            return moment.assets.count;
        }
    } else {
        //没按时间分组的情况
        if (_isShowCamera)
            return self.album.count + 1;
        else
            return self.album.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSTAssetModel *model;
    //判断显示相机, 如果显示相机，里面的代码。。。尽量理解。。不要问。。。我写完了都不太理解。。=-=
    // Don't ask about the following codes.
#warning !!!Waiting for updating 代码优化
    if (_isShowCamera) {
        if (self.config.isPhotosDesc) {
            if (_isMoment) {
                //根据时间分组
                MSTMoment *moment = _momentsArray[indexPath.section];
                
                if (!indexPath.item && !indexPath.section) {
                    //第一段第一个
                    return [self mp_addCameraCell:collectionView indexPath:indexPath];
                } else {
                    if (!indexPath.section)
                        //第一段
                        model = moment.assets[indexPath.item-1];
                    else
                        model = moment.assets[indexPath.item];
                }
            } else {
                //未根据之间分组
                if (!indexPath.item) {
                    //第一个
                    return [self mp_addCameraCell:collectionView indexPath:indexPath];
                } else {
                    model = self.album.models[indexPath.item-1];
                }
            }
        } else {
            if (_isMoment) {
                MSTMoment *moment = _momentsArray[indexPath.section];
                
                if (indexPath.section == _momentsArray.count - 1 && indexPath.item >= moment.assets.count)
                    return [self mp_addCameraCell:collectionView indexPath:indexPath];
                else
                    model = moment.assets[indexPath.item];
            } else {
                if (indexPath.item >= _album.count)
                    return [self mp_addCameraCell:collectionView indexPath:indexPath];
                else
                    model = self.album.models[indexPath.item];
            }
        }
    } else {
        if (_isMoment) {
            MSTMoment *moment = _momentsArray[indexPath.section];
            model = moment.assets[indexPath.item];
        } else {
            model = self.album.models[indexPath.item];
        }
    }
    MSTPhotoGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.asset = model;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    MSTMoment *moment = _momentsArray[indexPath.section];
    MSTPhotoGridHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MSTPhotoGridHeaderView" forIndexPath:indexPath];
    header.textLabel.text = [moment.date stringByPhotosMomentsType:self.config.photoMomentGroupType];
    
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *tmpIndexPath = indexPath;
    NSInteger item = 0;
    BOOL pushToCamera = NO;
    
    if (_isShowCamera) {
        if (self.config.isPhotosDesc) {
            if (_isMoment) {
                //根据时间分组
                if (!indexPath.item && !indexPath.section) {
                    //第一段第一个
                    pushToCamera = YES;
                } else {
                    if (!indexPath.section) {
                        //第一段
                        item = indexPath.item-1;
                    } else {
                        for (NSInteger i = 0; i < indexPath.section; i++) {
                            MSTMoment *moment = _momentsArray[i];
                            item += moment.assets.count;
                        }
                        item += indexPath.item;
                    }
                }
            } else {
                //未根据之间分组
                if (!indexPath.item) {
                    //第一个
                    pushToCamera = YES;
                } else {
                    item = indexPath.item-1;
                }
            }
        } else {
            if (_isMoment) {
                MSTMoment *moment = _momentsArray[indexPath.section];
                
                if (indexPath.section == _momentsArray.count - 1 && indexPath.item >= moment.assets.count) {
                    pushToCamera = YES;
                } else {
                    for (NSInteger i = 0; i < indexPath.section; i++) {
                        MSTMoment *moment = _momentsArray[i];
                        item += moment.assets.count;
                    }
                    item += indexPath.item;
                }
            } else {
                if (indexPath.item >= _album.count)
                    pushToCamera = YES;
                else
                    item = indexPath.item;
            }
        }
    } else {
        if (_isMoment) {
            for (NSInteger i = 0; i < indexPath.section; i++) {
                MSTMoment *moment = _momentsArray[i];
                item += moment.assets.count;
            }
            item += indexPath.item;
        } else {
            item = indexPath.item;
        }
    }
    
    if (pushToCamera) {
#warning waiting for updating 判断照相机授权。视频拍摄情况，判断语音授权。
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *pickerCtrler = [[UIImagePickerController alloc] init];
            pickerCtrler.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerCtrler.delegate = self;
            if (self.config.allowsMakingVideo) {
                pickerCtrler.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                pickerCtrler.videoMaximumDuration = self.config.videoMaximumDuration;
            }
            
            [self presentViewController:pickerCtrler animated:YES completion:nil];
        }
    } else {
        MSTPhotoPreviewController *ppc = [[MSTPhotoPreviewController alloc] init];
        ppc.hidesBottomBarWhenPushed = YES;
        ppc.delegate = self;
        
        [ppc didSelectedWithAlbum:_album item:item];
        
        [self.navigationController pushViewController:ppc animated:YES];
    }
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
#warning waiting for updating 不想这么暴力 T^T
            [self mp_refreshMoments];
            [collectionView reloadData];
        } else {
            //http://stackoverflow.com/questions/29337765/crash-attempt-to-delete-and-reload-the-same-index-path
            //本人好像是看不到哈。。=-=    不过，非常感谢！！！
#warning waiting for updating 虽然有一种方法搞定了。但是还是感觉会有更好的办法。
            if ([collectionChanges hasIncrementalChanges]) {
                BOOL isCamera = _isShowCamera && self.config.isPhotosDesc;
                
                NSArray <NSIndexPath *>*removedPaths = nil;
                NSArray <NSIndexPath *>*insertedPaths = nil;
                NSArray <NSIndexPath *>*changedPaths = nil;
                
                NSIndexSet *removedIndexes = collectionChanges.removedIndexes;
                if (removedIndexes.count > 0) {
                    removedPaths = [removedIndexes indexPathsFromIndexesWithSection:0 isShowCamera:isCamera];
                }
                
                NSIndexSet *insertedIndexes = collectionChanges.insertedIndexes;
                if (insertedIndexes.count > 0) {
                    insertedPaths = [insertedIndexes indexPathsFromIndexesWithSection:0 isShowCamera:isCamera];
                }
                
                NSIndexSet *changedIndexes = collectionChanges.changedIndexes;
                if (changedIndexes.count > 0) {
                    changedPaths = [changedIndexes indexPathsFromIndexesWithSection:0 isShowCamera:isCamera];
                }
                
                BOOL shouldReload = NO;
                if (changedPaths && removedPaths) {
                    for (NSIndexPath *changedPath in changedPaths) {
                        if ([removedPaths containsObject:changedPath]) {
                            shouldReload = YES;
                            break;
                        }
                    }
                }
                
                NSInteger item = _isShowCamera ? removedPaths.lastObject.item - 1 : removedPaths.lastObject.item;
                if (removedPaths.lastObject && item >= self.album.count) {
                    shouldReload = YES;
                }
                
                if (shouldReload) {
                    [collectionView reloadData];
                } else {
                    [collectionView performBatchUpdates:^{
                        if (removedPaths) [collectionView deleteItemsAtIndexPaths:removedPaths];
                        if (insertedIndexes) [collectionView insertItemsAtIndexPaths:insertedPaths];
                        if (changedPaths) [collectionView reloadItemsAtIndexPaths:changedPaths];
                        
                        if (collectionChanges.hasMoves) {
                            [collectionChanges enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                                NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                                NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                                [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                            }];
                        }
                    } completion:nil];
                }
            } else {
                [collectionView reloadData];
            }
        }
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            
            if (self.config.customAlbumName.length) {
                [[MSTPhotoManager sharedInstance] saveImageToCustomAlbumWithImage:image albumName:self.config.customAlbumName completionBlock:^(PHAsset *asset, NSString *error) {
                    if (error.length) NSLog(@"Save image to custom album error: %@", error);
                }];
            } else {
                //保存到系统相册
                [[MSTPhotoManager sharedInstance] saveImageToSystemAlbumWithImage:image completionBlock:^(PHAsset *asset, NSString *error) {
                    if (error.length) NSLog(@"Save image to system album error: %@", error);
                }];
            }
        } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            NSURL *url = info[UIImagePickerControllerMediaURL];
            
            if (self.config.customAlbumName.length) {
                //保存到自定义相册
                [[MSTPhotoManager sharedInstance] saveVideoToCustomAlbumWithURL:url albumName:self.config.customAlbumName completionBlcok:^(PHAsset *asset, NSString *error) {
                    if (error) NSLog(@"Save video to custom album error: %@", error);
                }];
            } else {
                [[MSTPhotoManager sharedInstance] saveVideoToSystemAlbumWithURL:url completionBlock:^(PHAsset *asset, NSString *error) {
                    if (error) NSLog(@"Save video to system album error: %@", error);
                }];
            }
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Fail to save media to album error: %@", error.description);
        }
    }];
}

#pragma mark - MSTPhotoGridCellDelegate
- (BOOL)gridCellSelectedButtonDidClicked:(BOOL)isSelected selectedAsset:(MSTAssetModel *)asset {
    MSTImagePickerController *pickerCtrler = (MSTImagePickerController *)self.navigationController;
    if (isSelected) {
        //选中
        return [pickerCtrler addSelectedAsset:asset];
    } else {
        //取消选中
        [pickerCtrler removeSelectedAsset:asset];
        return NO;
    }
}

#pragma mark - MSTPhotoPreviewControllerDelegate
- (void)photoPreviewDisappear {
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
}
@end
