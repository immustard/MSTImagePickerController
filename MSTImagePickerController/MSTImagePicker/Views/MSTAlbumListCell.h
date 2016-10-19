//
//  MSTAlbumListCell.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSTAlbumModel;

static NSString * const kAlbumCellReuserIdentifier = @"MSTAlbumListCellID";

@interface MSTAlbumListCell : UITableViewCell

@property (strong, nonatomic) UIImage *placeholderThumbnail;

@property (strong, nonatomic) MSTAlbumModel *albumModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
