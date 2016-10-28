//
//  MSTMoment.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/18.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTMoment.h"

@implementation MSTMoment

- (NSMutableArray <MSTAssetModel *>*)assets {
    if (!_assets) {
        self.assets = [NSMutableArray array];
    }
    return _assets;
}
@end
