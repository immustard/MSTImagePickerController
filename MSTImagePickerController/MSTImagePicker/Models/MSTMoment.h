//
//  MSTMoment.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/18.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoConfiguration.h"

@class MSTAssetModel;
@interface MSTMoment : NSObject

@property (strong, nonatomic) NSDateComponents *dateComponents;

@property (strong, nonatomic) NSDate *date;

@property (assign, nonatomic) MSTImageMomentGroupType groupType;

@property (strong, nonatomic) NSMutableArray <MSTAssetModel *>*assets;

@end
