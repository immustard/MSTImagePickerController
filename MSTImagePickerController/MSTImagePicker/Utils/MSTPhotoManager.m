//
//  MSTPhotoManager.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoManager.h"
#import "UIImage+MSTUtiles.h"
#import "MSTAlbumModel.h"
#import "MSTMoment.h"

@interface MSTPhotoManager ()
@property (strong, nonatomic) PHImageManager *imageManager;
@property (strong, nonatomic) PHCachingImageManager *cacheImageManager;
@end

@implementation MSTPhotoManager

+ (instancetype)sharedInstance{
    static MSTPhotoManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MSTPhotoManager alloc] init];
    });
    
    return instance;
}

+ (void)checkAuthorizationStatusWithSourceType:(MSTImagePickerSourceType)type callBack:(void (^)(MSTImagePickerSourceType, MSTAuthorizationStatus))callBackBlock {
    switch (type) {
        case MSTImagePickerSourceTypePhoto: {
            if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    callBackBlock ? callBackBlock(type, (MSTAuthorizationStatus)status) : nil;
                }];
            } else {
                callBackBlock ? callBackBlock(type, MSTAuthorizationStatusAuthorized) : nil;
            }
        }
            break;
        case MSTImagePickerSourceTypeSound: {
            
        }
            break;
        case MSTImagePickerSourceTypeCamera: {
            
        }
            break;
    }
}

#pragma mark - Load
- (void)loadCameraRollInfoisDesc:(BOOL)isDesc isShowEmpty:(BOOL)isShowEmpty isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(MSTAlbumModel *))completionBlock {
    PHFetchResult *albumCollection= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    [albumCollection enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:!isDesc]];
        if (isOnlyShowImage) {
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
        }
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:fetchOptions];

        MSTAlbumModel *model = nil;
        
        if (result.count > 0 || isShowEmpty) {
            model = [MSTAlbumModel new];
            model.isCameraRoll = YES;
            model.albumName = obj.localizedTitle;//相册名
            model.content = result;//保存这个相册的内容
        }
        
        completionBlock ? completionBlock(model) : nil;
    }];
}

- (void)loadAlbumInfoIsShowEmpty:(BOOL)isShowEmpty isDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(PHFetchResult *, NSArray *))completionBlock {
    //用来存放每个相册的model
    NSMutableArray *albumModelsArray = [NSMutableArray array];
    
    //创建读取相册信息的options
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:!isDesc]];
    if (isOnlyShowImage) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    }
    
    [self loadCameraRollInfoisDesc:isDesc isShowEmpty:isShowEmpty isOnlyShowImage:isOnlyShowImage CompletionBlock:^(MSTAlbumModel *result) {
        [albumModelsArray addObject:result];
    }];
    
    PHFetchResult *albumsCollection2 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    
    [albumsCollection2 enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {

        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        
        if (assetsResult.count > 0 || isShowEmpty) {
            MSTAlbumModel *model = [MSTAlbumModel new];
            model.isCameraRoll = NO;
            model.albumName = collection.localizedTitle;
            model.content = assetsResult;
            
            [albumModelsArray addObject:model];
        }
        
    }];
    
    //回调
    completionBlock ? completionBlock(albumsCollection2, albumModelsArray) : nil;
}

#pragma mark - Save
- (void)saveImageToSystemAlbumWithImage:(UIImage *)image completionBlock:(void (^)(PHAsset *, NSString *))completionBlock {
    __block NSString *createdAssetID = nil;
    
    // 保存图片
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;

    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //获取保存到系统相册成功后的 asset
        PHAsset *creatAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil].firstObject;
        
        //回调
        completionBlock ? completionBlock(creatAsset, error.description) : nil;
    }];
}

- (void)saveImageToCustomAlbumWithImage:(UIImage *)image albumName:(NSString *)albumName completionBlock:(void (^)(PHAsset *, NSString *))completionBlock {
    //先保存到系统相册中
    __weak typeof(self) weakSelf = self;
    [self saveImageToSystemAlbumWithImage:image completionBlock:^(PHAsset *asset, NSString *error) {
        //非空判断
        if (asset) {
            PHAssetCollection *collection = [weakSelf mp_getAssetCollectionWithCustomAlbumName:albumName];
            
            if (!collection) return ;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                completionBlock ? completionBlock(asset, error.description) : nil;
            }];
        }
    }];
}

- (void)saveVideoToSystemAlbumWithURL:(NSURL *)url completionBlock:(void (^)(PHAsset *, NSString *))completionBlock {
    __block NSString *createdAssetID = nil;
    
    // 保存图片
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //获取保存到系统相册成功后的 asset
        PHAsset *creatAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil].firstObject;
        
        //回调
        completionBlock ? completionBlock(creatAsset, error.description) : nil;
    }];
}

- (void)saveVideoToCustomAlbumWithURL:(NSURL *)url albumName:(NSString *)albumName completionBlcok:(void (^)(PHAsset *, NSString *))completionBlock {
    __weak typeof(self) weakSelf = self;
    [self saveVideoToSystemAlbumWithURL:url completionBlock:^(PHAsset *asset, NSString *error) {
        if (asset) {
            PHAssetCollection *collection = [weakSelf mp_getAssetCollectionWithCustomAlbumName:albumName];
            
            if (!collection) return ;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                completionBlock ? completionBlock(asset, error.description) : nil;
            }];
        }
    }];
}

- (PHAssetCollection *)mp_getAssetCollectionWithCustomAlbumName:(NSString *)customName {
    //获取所有相册
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //遍历
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:customName]) {
            return collection;
        }
    }
    
    //创建
    NSError *error = nil;
    __block NSString * createId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:customName];
        createId = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        //创建失败
        NSLog(@"Fail to create the custom album.");
        return nil;
    } else {
        //创建成功
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createId] options:nil].firstObject;
    }
}

- (NSArray<MSTMoment *> *)sortByMomentType:(MSTImageMomentGroupType)momentType assets:(NSArray *)models {
    MSTMoment *newMoment = nil;
    
    NSMutableArray *groups = [NSMutableArray array];
    
    for (NSInteger i = 0; i < models.count; i++) {
        MSTAssetModel *asset = models[i];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:asset.asset.creationDate];
        
        NSUInteger year = components.year;
        NSUInteger month = components.month;
        NSUInteger day = components.day;
        
        switch (momentType) {
            case MSTImageMomentGroupTypeYear:
                if (newMoment && newMoment.dateComponents.year == year) break;
            case MSTImageMomentGroupTypeMonth:
                if (newMoment && newMoment.dateComponents.year == year && newMoment.dateComponents.month == month) break;
            case MSTImageMomentGroupTypeDay:
                if (newMoment && newMoment.dateComponents.year == year && newMoment.dateComponents.month == month && newMoment.dateComponents.day == day) break;
            default:
                newMoment = [MSTMoment new];
                newMoment.dateComponents = components;
                newMoment.date = asset.asset.creationDate;
                [groups addObject:newMoment];
                break;
        }
        [newMoment.assets addObject:asset];
    }
    return groups;
}

#pragma mark - Get
- (void)getMSTAssetModelWithPHFetchResult:(PHFetchResult *)fetchResult completionBlock:(void (^)(NSArray<MSTAssetModel *> *))completionBlock {
    NSMutableArray *modelsArray = [NSMutableArray arrayWithCapacity:fetchResult.count];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        MSTAssetModel *model = [MSTAssetModel modelWithAsset:asset];
        
        [modelsArray addObject:model];
    }];
    completionBlock ? completionBlock(modelsArray) : nil;
}

- (void)getThumbnailImageFromPHAsset:(PHAsset *)asset photoWidth:(CGFloat)width completionBlock:(void (^)(UIImage *, NSDictionary *))completionBlock {
    [self mp_getImageFromPHAsset:asset imageSize:CGSizeMake(width * 2.f, width * 2.f) isSynchronous:NO isFixOrientation:NO completionBlock:^(UIImage *result, NSDictionary *info) {
        completionBlock ? completionBlock(result, info) : nil;
    }];
}

- (void)getPreviewImageFromPHAsset:(PHAsset *)asset isHighQuality:(BOOL)isHighQuality completionBlock:(void (^)(UIImage *, NSDictionary *, BOOL))completionBlock {
    CGFloat scale = isHighQuality ? [UIScreen mainScreen].scale : .1f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale;
    CGFloat pixelHeight = width / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    [self mp_getImageFromPHAsset:asset imageSize:imageSize isSynchronous:NO isFixOrientation:YES completionBlock:^(UIImage *result, NSDictionary *info) {
        completionBlock ? completionBlock(result, info, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
    }];
}

- (void)mp_getImageFromPHAsset:(PHAsset *)asset imageSize:(CGSize)imageSize isSynchronous:(BOOL)synchronous isFixOrientation:(BOOL)fixOrientation completionBlock:(void(^)(UIImage *result, NSDictionary *info))completionBlock {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = synchronous;
    
    [self.imageManager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL finished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (finished && result) {
            if (fixOrientation) result = [UIImage fixOrientation:result];
            
            //回调
            completionBlock ? completionBlock(result, info) : nil;
        }
    }];
}

- (void)getLivePhotoFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(PHLivePhoto *))completionBlock {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale;
    CGFloat pixelHeight = width / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    
    [self.imageManager requestLivePhotoForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        completionBlock ? completionBlock(livePhoto) : nil;
    }];
}

- (void)getOriginImageFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(UIImage *))completionBlock{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.synchronous = NO;
    
    [self.cacheImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        result = [UIImage fixOrientation:result];

        completionBlock ? completionBlock(result) : nil;
    }];
}

- (void)getAVPlayerItemFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(AVPlayerItem *))completionBlock {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.version = PHVideoRequestOptionsVersionOriginal;
    
    [self.imageManager requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        completionBlock ? completionBlock(playerItem) : nil;
    }];
}

- (void)getImageBytesWithArray:(NSArray<MSTAssetModel *> *)models completionBlock:(void (^)(NSString *))completionBlock {
    __block NSUInteger dataLength = 0;
    __block NSUInteger count = models.count;
    for (MSTAssetModel *model in models) {
        [self.imageManager requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            count--;
            dataLength += imageData.length;
            if (count <= 0) {
                completionBlock ? completionBlock([self mp_getBytesStringWithDataLength:dataLength]) : nil;
            }
        }];
    }
}

- (NSString *)mp_getBytesStringWithDataLength:(NSUInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%.02fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%.02fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%ziB",dataLength];
    }
    return bytes;
}

#pragma mark - Lazy Load
- (PHCachingImageManager *)cacheImageManager{
    if (_cacheImageManager == nil) {
        self.cacheImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cacheImageManager;
}

- (PHImageManager *)imageManager {
    if (!_imageManager) {
        self.imageManager = [PHImageManager defaultManager];
    }
    return _imageManager;
}

@end
