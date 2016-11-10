//
//  MSTAlbumModel.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAlbumModel.h"
#import "MSTPhotoManager.h"

@implementation MSTAlbumModel

- (NSUInteger)count {
    return self.models.count;
}

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> albumName:%@ | count:%zi", [self class], self, self.albumName, self.count];
}

- (void)setContent:(PHFetchResult *)content {
    _content = content;
    
    [[MSTPhotoManager defaultManager] getMSTAssetModelWithPHFetchResult:content completionBlock:^(NSArray<MSTAssetModel *> *models) {
        self.models = models;
    }];
}

@end
