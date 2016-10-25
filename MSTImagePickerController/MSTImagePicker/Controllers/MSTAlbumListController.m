//
//  MSTAlbumListController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAlbumListController.h"
#import "MSTPhotoGridController.h"
#import "MSTPhotoManager.h"
#import "MSTAlbumModel.h"
#import "MSTPhotoConfiguration.h"
#import "MSTAlbumListCell.h"

@interface MSTAlbumListController ()<PHPhotoLibraryChangeObserver> {
    PHFetchResult *_colletionResult;
}
@property (strong, nonatomic) NSArray *albumModelsArray;
@end

@implementation MSTAlbumListController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mp_initData];
    [self mp_setupViews];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Instance Methods
- (void)mp_initData {
    __weak typeof(self) weakSelf = self;
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    //读取相册信息
    [[MSTPhotoManager sharedInstance] loadAlbumInfoIsShowEmpty:config.isShowEmptyAlbum isDesc:config.isPhotosDesc isOnlyShowImage:config.isOnlyShowImages CompletionBlock:^(PHFetchResult *customAlbum, NSArray *albumModelArray) {
        _colletionResult = customAlbum;
        weakSelf.albumModelsArray = albumModelArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)mp_setupViews {
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumModelsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    
    MSTAlbumModel *model = self.albumModelsArray[indexPath.row];
    
    if (config.isShowAlbumThumbnail) {
        MSTAlbumListCell *cell = [MSTAlbumListCell cellWithTableView:tableView];
        
        cell.placeholderThumbnail = self.placeholderThumbnail;
        cell.albumModel = model;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuserIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAlbumCellReuserIdentifier];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = model.albumName;
        
        if (config.isShowAlbumNumber) cell.detailTextLabel.text = [NSString stringWithFormat:@"(%zd)", model.count];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MSTPhotoConfiguration *config = [MSTPhotoConfiguration defaultConfiguration];
    MSTPhotoGridController *pgc = [[MSTPhotoGridController alloc] initWithCollectionViewLayout:[MSTPhotoGridController flowLayoutWithNumInALine:config.numsInRow]];
    pgc.album = self.albumModelsArray[indexPath.row];
    [self.navigationController pushViewController:pgc animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // 检测是否有资源变化
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:_colletionResult];
    if (!collectionChanges) {
        return;
    }

    [self mp_initData];
}
@end
